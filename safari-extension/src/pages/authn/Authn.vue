<script setup lang="ts">
import { onMounted } from "vue";
import browser from "webextension-polyfill";

onMounted(() => {
  console.log("authn vue component mounted");
  setTimeout(() => {
    browser.runtime.sendMessage("haha");
  }, 2000);
});
</script>

<template>
  <h1 class="text-3xl font-bold text-red-500 underline">Authn!</h1>
</template>
