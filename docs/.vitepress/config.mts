import { defineConfig } from "vitepress";

export default defineConfig({
  title: "Klima",
  description: "Weather resilience platform — docs scaffold",
  srcExclude: ["mvp/**", "handoffs/**"],
  themeConfig: {
    nav: [
      { text: "Home", link: "/" },
      { text: "Getting started", link: "/getting-started" },
      { text: "Deploy", link: "/deploy" },
    ],
    sidebar: [
      {
        text: "Guide",
        items: [
          { text: "Home", link: "/" },
          { text: "Getting started", link: "/getting-started" },
          { text: "Deployments", link: "/deploy" },
        ],
      },
    ],
  },
});
