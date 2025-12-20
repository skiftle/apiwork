<script setup lang="ts">
import { onMounted, onUnmounted } from "vue";
import { data } from "../../data/homepage.data";
import HeroSection from "./HeroSection.vue";
import WhySection from "./WhySection.vue";
import GeneratorsSection from "./GeneratorsSection.vue";
import FeatureSection from "./FeatureSection.vue";
import MoreFeaturesSection from "./MoreFeaturesSection.vue";

const { features } = data;

let observer: IntersectionObserver | null = null;

onMounted(() => {
  observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
        }
      });
    },
    { threshold: 0.1, rootMargin: "0px 0px -50px 0px" }
  );

  document.querySelectorAll(".animate-on-scroll").forEach((el) => {
    observer?.observe(el);
  });
});

onUnmounted(() => {
  observer?.disconnect();
});
</script>

<template>
  <div class="home-layout">
    <HeroSection />
    <WhySection class="animate-on-scroll" />
    <GeneratorsSection />

    <FeatureSection
      v-for="(feature, index) in features"
      :key="index"
      :feature="feature"
      class="animate-on-scroll"
    />

    <MoreFeaturesSection class="animate-on-scroll" />
  </div>
</template>

<style scoped>
.home-layout {
  min-height: calc(100vh - var(--header-height));
}

.animate-on-scroll {
  opacity: 0;
  transform: translateY(40px);
  transition: opacity 0.8s cubic-bezier(0.16, 1, 0.3, 1),
    transform 0.8s cubic-bezier(0.16, 1, 0.3, 1);

  &.is-visible {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-on-scroll :deep(.code) {
  opacity: 0;
  transform: translateY(20px) scale(0.98);
  transition: opacity 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s,
    transform 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s;
}

.animate-on-scroll.is-visible :deep(.code) {
  opacity: 1;
  transform: translateY(0) scale(1);
}
</style>
