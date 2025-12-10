import type { Theme } from "vitepress";
import Layout from "./Layout.vue";
import "./styles/base.css";

export default {
  Layout,
  enhanceApp({ app }) {
    // TODO: Register global components if needed
  },
} satisfies Theme;
