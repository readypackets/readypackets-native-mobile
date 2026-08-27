package com.readypackets.mobile.core

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Test

class DocumentCacheTest {
    @Test fun `cache keys are stable non-enumerable hashes`() {
        val first = DocumentCache.cacheKey("sealed-mobile-file-reference")
        assertEquals(first, DocumentCache.cacheKey("sealed-mobile-file-reference"))
        assertNotEquals(first, DocumentCache.cacheKey("different-sealed-mobile-file-reference"))
        assertEquals(64, first.length)
    }
}
