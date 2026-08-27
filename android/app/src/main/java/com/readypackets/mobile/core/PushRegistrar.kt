package com.readypackets.mobile.core

import android.content.Context
import android.os.Build
import com.google.android.gms.tasks.Tasks
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/** Registers FCM token only after Portal OAuth succeeds; no provider secret is present in the app. */
class PushRegistrar(private val context: Context, private val api: MobileApiClient) {
    suspend fun register(): Result<DeviceRegistrationReply> = withContext(Dispatchers.IO) {
        runCatching { Tasks.await(FirebaseMessaging.getInstance().token) }.fold(
            onSuccess = { token -> api.post<DeviceRegistrationReply, DeviceRegistration>("/devices", payload(token)) },
            onFailure = { Result.failure(IllegalStateException("Push registration is unavailable until Firebase is configured for this build.", it)) },
        )
    }
    private fun payload(token: String) = DeviceRegistration(
        deviceId = installationId(context), platform = "android", appVersion = com.readypackets.mobile.BuildConfig.VERSION_NAME,
        deviceName = "${Build.MANUFACTURER} ${Build.MODEL}".take(128), pushPlatform = "fcm", pushToken = token,
    )
    companion object {
        fun installationId(context: Context): String = context.getSharedPreferences("readypackets_installation", Context.MODE_PRIVATE).getString("id", null)
            ?: java.util.UUID.randomUUID().toString().lowercase().also { context.getSharedPreferences("readypackets_installation", Context.MODE_PRIVATE).edit().putString("id", it).apply() }
    }
}
