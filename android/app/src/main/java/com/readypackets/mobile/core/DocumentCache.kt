package com.readypackets.mobile.core

import android.content.Context
import androidx.security.crypto.EncryptedFile
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import java.io.File
import java.security.MessageDigest

/**
 * Customer-controlled offline document storage. Cached bytes are encrypted in
 * app-private storage and every entry is removed at explicit sign-out.
 */
class DocumentCache(context: Context) {
    private val appContext = context.applicationContext
    private val key = MasterKey.Builder(appContext).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build()
    private val root = File(appContext.filesDir, "readypackets-customer-documents").apply { mkdirs() }
    private val index = EncryptedSharedPreferences.create(
        appContext,
        "readypackets_customer_document_index",
        key,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
    )

    fun save(reference: String, originalName: String, bytes: ByteArray): Result<Unit> = runCatching {
        require(bytes.isNotEmpty()) { "The document was empty." }
        val cacheKey = cacheKey(reference)
        val target = File(root, "$cacheKey.rpk")
        target.delete()
        EncryptedFile.Builder(
            appContext,
            target,
            key,
            EncryptedFile.FileEncryptionScheme.AES256_GCM_HKDF_4KB,
        ).build().openFileOutput().use { it.write(bytes) }
        index.edit().putString(cacheKey, originalName.take(255)).apply()
    }

    fun isCached(reference: String): Boolean = index.contains(cacheKey(reference)) && File(root, "${cacheKey(reference)}.rpk").isFile

    fun read(reference: String): Result<ByteArray> = runCatching {
        val cacheKey = cacheKey(reference)
        require(index.contains(cacheKey)) { "This file is not available offline." }
        val target = File(root, "$cacheKey.rpk")
        require(target.isFile) { "This offline file is no longer available." }
        EncryptedFile.Builder(
            appContext,
            target,
            key,
            EncryptedFile.FileEncryptionScheme.AES256_GCM_HKDF_4KB,
        ).build().openFileInput().use { it.readBytes() }
    }

    fun clear() {
        root.listFiles()?.forEach { it.delete() }
        index.edit().clear().apply()
    }

    companion object {
        fun cacheKey(reference: String): String = MessageDigest.getInstance("SHA-256")
            .digest(reference.toByteArray(Charsets.UTF_8))
            .joinToString("") { "%02x".format(it) }
    }
}
