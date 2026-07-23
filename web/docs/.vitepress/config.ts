import { defineConfig } from "vitepress";

export default defineConfig({
  title: "Klima",
  description: "Weather resilience platform — docs scaffold",
  themeConfig: {
    nav: [
      { text: "Home", link: "/" },
      { text: "Getting started", link: "/getting-started" },
    ],
    sidebar: [
      {
        text: "Guide",
        items: [
          { text: "Home", link: "/" },
          { text: "Getting started", link: "/getting-started" },
        ],
      },
    ],
  },
});
