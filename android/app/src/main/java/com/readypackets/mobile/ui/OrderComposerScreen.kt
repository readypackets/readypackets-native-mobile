package com.readypackets.mobile.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import com.readypackets.mobile.core.*
import kotlinx.coroutines.launch

@Composable
fun OrderComposerScreen(container: AppContainer, onClose: () -> Unit, onCreated: () -> Unit) {
    var catalog by remember { mutableStateOf<CatalogPage?>(null) }
    var selections by remember { mutableStateOf<Map<String, String>>(emptyMap()) }
    var projectName by remember { mutableStateOf("") }
    var creating by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<String?>(null) }
    var reply by remember { mutableStateOf<CreateOrderReply?>(null) }
    val scope = rememberCoroutineScope()

    LaunchedEffect(Unit) {
        container.api().get<CatalogPage>("/catalog").onSuccess { catalog = it }.onFailure { error = it.message }
    }

    if (reply != null) {
        val created = reply!!
        Column(Modifier.fillMaxSize().padding(24.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
            Text("Order recorded", style = MaterialTheme.typography.headlineMedium)
            Text(created.order.publicOrderId, style = MaterialTheme.typography.titleMedium, color = Teal)
            Text(created.message, style = MaterialTheme.typography.bodyLarge)
            ElevatedCard { Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(if (created.order.requiresCustomQuote) "Quote required" else "Payment required", style = MaterialTheme.typography.titleMedium)
                Text(if (created.order.requiresCustomQuote) "ReadyPackets will prepare your quote in the Portal. Work begins only after the server confirms the next step." else "Complete payment through the secure ReadyPackets Portal. The mobile client never collects card data.")
            } }
            Button(onClick = { onCreated(); onClose() }, colors = ButtonDefaults.buttonColors(containerColor = Teal), modifier = Modifier.fillMaxWidth()) { Text("Return to orders") }
        }
        return
    }

    LazyColumn(Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
        item { TextButton(onClick = onClose) { Text("Back to orders") } }
        item { Text("Place an order", style = MaterialTheme.typography.headlineMedium) }
        item { Text("Choose one listed packet from each group. The Portal verifies availability, pricing, payment, workflow, and the final order record.", style = MaterialTheme.typography.bodyLarge) }
        item { OutlinedTextField(value = projectName, onValueChange = { projectName = it.take(160) }, label = { Text("Project name (optional)") }, supportingText = { Text("Up to 160 characters") }, modifier = Modifier.fillMaxWidth(), singleLine = true) }
        error?.let { message -> item { Text(message, color = Danger, style = MaterialTheme.typography.bodyMedium) } }
        if (catalog == null && error == null) item { CircularProgressIndicator(color = Teal) }
        items(catalog?.items.orEmpty(), key = { it.slug }) { group ->
            ElevatedCard { Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("${group.number}. ${group.name}", style = MaterialTheme.typography.titleMedium)
                group.summary?.let { Text(it, style = MaterialTheme.typography.bodySmall) }
                group.packets.forEach { packet ->
                    val selected = selections[group.slug] == packet.sku
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Row(Modifier.weight(1f), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            RadioButton(selected = selected, onClick = { selections = selections.toMutableMap().apply { put(group.slug, packet.sku) } })
                            Column { Text(packet.name, style = MaterialTheme.typography.bodyLarge); Text(packet.description ?: packet.outcome ?: packet.deliveryEstimate, style = MaterialTheme.typography.bodySmall); Text(packet.priceCents?.let { currency(it) } ?: "Custom quote", style = MaterialTheme.typography.labelLarge, color = Teal) }
                        }
                    }
                }
            } }
        }
        item {
            Button(
                enabled = selections.isNotEmpty() && !creating,
                onClick = {
                    creating = true; error = null
                    scope.launch {
                        val request = CreateOrderRequest(selections = selections.values.map { OrderSelection(it) }, projectName = projectName.trim().ifBlank { null })
                        container.api().post<CreateOrderReply, CreateOrderRequest>("/orders", request)
                            .onSuccess { reply = it }
                            .onFailure { error = it.message }
                        creating = false
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = Teal),
                modifier = Modifier.fillMaxWidth().heightIn(min = 52.dp),
            ) { Text(if (creating) "Recording order…" else "Record selected packets") }
            Text("Prices and payment action are confirmed by the Portal after submission. Do not submit confidential payment data in this app.", style = MaterialTheme.typography.bodySmall, modifier = Modifier.padding(top = 10.dp))
        }
    }
}

private fun currency(cents: Int): String = "${'$'}" + "%,d".format(java.util.Locale.US, cents / 100) + ".%02d".format(java.util.Locale.US, cents % 100)
