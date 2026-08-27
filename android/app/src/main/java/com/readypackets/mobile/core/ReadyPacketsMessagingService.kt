package com.readypackets.mobile.core

import com.google.firebase.messaging.FirebaseMessagingService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/** Refreshes server registration when FCM rotates a device token. */
class ReadyPacketsMessagingService : FirebaseMessagingService() {
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        CoroutineScope(Dispatchers.IO).launch {
            val api = MobileApiClient(SecureTokenStore(applicationContext))
            PushRegistrar(applicationContext, api).register()
        }
    }
}
