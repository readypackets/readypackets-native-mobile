package com.readypackets.mobile.ui

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaPlayer
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import com.readypackets.mobile.core.*
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable
import java.io.File

@Serializable private data class IntakeRequest(val projectName: String? = null)
@Serializable private data class StageRequest(val acknowledged: Boolean, val acknowledgementText: String)
@Serializable private data class MessageRequest(val body: String)
@Serializable private data class EmptyRequest(val request: String? = null)

/** Customer work surface. The Portal remains the authority for every stage and upload permission. */
@Composable
fun OrdersScreen(container: AppContainer) {
    var orders by remember { mutableStateOf<List<OrderSummary>>(emptyList()) }
    var error by remember { mutableStateOf<String?>(null) }
    var selected by remember { mutableStateOf<OrderSummary?>(null) }
    var composing by remember { mutableStateOf(false) }
    var refreshKey by remember { mutableIntStateOf(0) }

    LaunchedEffect(refreshKey) {
        container.api().get<OrdersPage>("/orders?limit=50")
            .onSuccess { orders = it.items }
            .onFailure { error = it.message }
    }
    when {
        composing -> OrderComposerScreen(container, onClose = { composing = false }, onCreated = { refreshKey++ })
        selected != null -> CustomerOrderDetailScreen(container, selected!!, onBack = { selected = null })
        else -> LazyColumn(Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            item {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text("Orders", style = MaterialTheme.typography.headlineMedium)
                    Button(onClick = { composing = true }, colors = ButtonDefaults.buttonColors(containerColor = Teal)) { Text("Place order") }
                }
            }
            item { Text("Create a request from listed packets. The Portal confirms pricing, payment, and activation.") }
            error?.let { item { Text(it, color = Danger) } }
            items(orders, key = { it.publicOrderId }) { order ->
                ElevatedCard(onClick = { selected = order }) {
                    Column(Modifier.padding(16.dp)) {
                        Text(order.projectName ?: order.publicOrderId, style = MaterialTheme.typography.titleMedium)
                        Text(order.currentStage ?: order.status)
                        Spacer(Modifier.height(8.dp))
                        LinearProgressIndicator(progress = { order.completionPercent / 100f }, modifier = Modifier.fillMaxWidth(), color = Teal)
                        Text("${order.completionPercent}%", style = MaterialTheme.typography.labelMedium)
                        if (order.attention != "none") Text("Action needed", color = Danger, style = MaterialTheme.typography.labelLarge)
                    }
                }
            }
        }
    }
}

@Composable
private fun CustomerOrderDetailScreen(container: AppContainer, summary: OrderSummary, onBack: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val recorder = remember { AudioCapture() }
    var detail by remember { mutableStateOf<CustomerOrderDetail?>(null) }
    var files by remember { mutableStateOf<List<CustomerFile>>(emptyList()) }
    var invoice by remember { mutableStateOf<Invoice?>(null) }
    var error by remember { mutableStateOf<String?>(null) }
    var message by remember { mutableStateOf("") }
    var recording by remember { mutableStateOf(false) }
    var player by remember { mutableStateOf<MediaPlayer?>(null) }
    val phaseKey = detail?.workflow?.stages?.firstOrNull()?.key ?: "phase_1_intake"

    suspend fun refresh() {
        container.api().get<CustomerOrderDetail>("/customer/orders/${summary.publicOrderId}/detail")
            .onSuccess { detail = it }.onFailure { error = it.message }
        container.api().get<CustomerFilesPage>("/customer/orders/${summary.publicOrderId}/files")
            .onSuccess { files = it.items }.onFailure { error = it.message }
        container.api().get<Invoice>("/customer/orders/${summary.publicOrderId}/invoice")
            .onSuccess { invoice = it }
    }
    LaunchedEffect(summary.publicOrderId) { refresh() }
    DisposableEffect(Unit) { onDispose { player?.release(); recorder.release() } }

    suspend fun upload(localFiles: List<File>, recordedAudio: Boolean) {
        container.api().upload(
            "/customer/orders/${summary.publicOrderId}/uploads", localFiles,
            mapOf("phase" to phaseKey, "recordedAudio" to recordedAudio.toString(), "prerecordedAudio" to "false"),
        ).onSuccess { files = files + it.items }.onFailure { error = it.message }
        localFiles.forEach { it.delete() }
    }
    val documents = rememberLauncherForActivityResult(ActivityResultContracts.OpenMultipleDocuments()) { uris ->
        if (uris.isNotEmpty()) scope.launch {
            val selected = uris.take(5).mapNotNull { uri ->
                runCatching {
                    context.contentResolver.openInputStream(uri)?.use { input ->
                        File.createTempFile("readypackets-", ".upload", context.cacheDir).also { target -> target.outputStream().use { input.copyTo(it) } }
                    }
                }.getOrNull()
            }
            if (selected.isEmpty()) error = "The selected files could not be opened." else upload(selected, false)
        }
    }
    val micPermission = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        if (!granted) error = "Microphone access is required to record an order response."
        else recorder.start(context).onSuccess { recording = true }.onFailure { error = it.message }
    }

    LazyColumn(Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
        item {
            TextButton(onClick = onBack) { Text("Back to orders") }
            Text(detail?.order?.projectName ?: summary.projectName ?: summary.publicOrderId, style = MaterialTheme.typography.headlineSmall)
        }
        item {
            ElevatedCard {
                Column(Modifier.padding(16.dp)) {
                    Text(detail?.workflowProgress?.currentPhaseLabel ?: detail?.order?.statusLabel ?: summary.currentStage ?: summary.status, style = MaterialTheme.typography.titleMedium)
                    LinearProgressIndicator(progress = { (detail?.order?.completionPercent ?: summary.completionPercent) / 100f }, modifier = Modifier.fillMaxWidth(), color = Teal)
                    Text("Payment status: ${detail?.order?.paymentStatus ?: summary.paymentStatus}")
                }
            }
        }
        item {
            Text("Workflow", style = MaterialTheme.typography.titleLarge)
            Text(detail?.workflow?.customerPresentation ?: "ReadyPackets shows only your authorised current-stage actions.")
            detail?.workflow?.stages?.forEach { stage -> Text("• ${stage.label ?: stage.key}", style = MaterialTheme.typography.bodyMedium) }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = { scope.launch { container.api().put<EmptyReply, IntakeRequest>("/customer/orders/${summary.publicOrderId}/intake", IntakeRequest(detail?.order?.projectName)).onFailure { error = it.message } } }) { Text("Save intake") }
                Button(onClick = { scope.launch { container.api().post<EmptyReply, StageRequest>("/customer/orders/${summary.publicOrderId}/workflow/$phaseKey/submit", StageRequest(true, "I confirm this customer workflow submission is accurate.")).onSuccess { refresh() }.onFailure { error = it.message } } }, colors = ButtonDefaults.buttonColors(containerColor = Teal)) { Text("Submit stage") }
            }
        }
        item {
            Text("Files and audio", style = MaterialTheme.typography.titleLarge)
            Text("Files and recordings are accepted only when the Portal authorises the selected workflow stage.", style = MaterialTheme.typography.bodySmall)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = { documents.launch(arrayOf("application/pdf", "image/*", "audio/*", "text/plain", "application/octet-stream")) }) { Text("Choose files") }
                Button(
                    onClick = {
                        if (recording) recorder.stop()?.let { file -> recording = false; scope.launch { upload(listOf(file), true) } }
                        else if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) recorder.start(context).onSuccess { recording = true }.onFailure { error = it.message }
                        else micPermission.launch(Manifest.permission.RECORD_AUDIO)
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = if (recording) Danger else Teal),
                ) { Text(if (recording) "Stop recording" else "Record audio") }
            }
        }
        items(files, key = { it.mobileFileRef }) { file ->
            ElevatedCard {
                Row(Modifier.fillMaxWidth().padding(14.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                    Column(Modifier.weight(1f)) {
                        Text(file.originalName, style = MaterialTheme.typography.titleSmall)
                        Text("${file.sizeBytes / 1024} KB${file.durationSeconds?.let { " · ${it.toInt()} sec" } ?: ""}", style = MaterialTheme.typography.labelSmall)
                    }
                    Row {
                        if (file.audio) TextButton(onClick = { scope.launch {
                            container.api().getBytes("/customer/files/${file.mobileFileRef}/content?disposition=inline").onSuccess { bytes ->
                                val local = File.createTempFile("readypackets-play-", ".m4a", context.cacheDir); local.writeBytes(bytes)
                                player?.release(); player = MediaPlayer().apply { setDataSource(local.absolutePath); prepare(); start() }
                            }.onFailure { error = it.message }
                        } }) { Text("Play") }
                        TextButton(onClick = { scope.launch {
                            container.api().getBytes("/customer/files/${file.mobileFileRef}/content").onSuccess { bytes ->
                                File(context.getExternalFilesDir("downloads"), file.originalName).apply { parentFile?.mkdirs(); writeBytes(bytes) }
                            }.onFailure { error = it.message }
                        } }) { Text("Save") }
                    }
                }
            }
        }
        item {
            Text("Invoice and payment", style = MaterialTheme.typography.titleLarge)
            if (invoice != null) {
                Text(invoice!!.invoiceNumber)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Button(onClick = { scope.launch {
                        container.api().getBytes("/customer/orders/${summary.publicOrderId}/invoice/content").onSuccess { bytes ->
                            File(context.getExternalFilesDir("downloads"), "${invoice!!.invoiceNumber}.pdf").apply { parentFile?.mkdirs(); writeBytes(bytes) }
                        }.onFailure { error = it.message }
                    } }) { Text("Save invoice") }
                    if (detail?.order?.paymentStatus != "paid") Button(onClick = { scope.launch {
                        container.api().post<CheckoutHandoff, EmptyRequest>("/customer/orders/${summary.publicOrderId}/checkout-handoff", EmptyRequest()).onSuccess { handoff ->
                            context.startActivity(Intent(Intent.ACTION_VIEW, android.net.Uri.parse(handoff.checkoutUrl)))
                        }.onFailure { error = it.message }
                    } }, colors = ButtonDefaults.buttonColors(containerColor = Gold)) { Text("Pay in Portal") }
                }
            } else Text("Invoices are available after the Portal publishes them. Card details are never entered in the app.")
        }
        item {
            Text("Message ReadyPackets", style = MaterialTheme.typography.titleLarge)
            OutlinedTextField(message, { message = it }, label = { Text("Secure message") }, modifier = Modifier.fillMaxWidth().heightIn(min = 110.dp))
            Button(onClick = { scope.launch {
                container.api().post<EmptyReply, MessageRequest>("/customer/orders/${summary.publicOrderId}/messages", MessageRequest(message)).onSuccess { message = "" }.onFailure { error = it.message }
            } }, enabled = message.isNotBlank(), colors = ButtonDefaults.buttonColors(containerColor = Teal)) { Text("Send secure message") }
        }
        error?.let { item { Text(it, color = Danger) } }
    }
}
