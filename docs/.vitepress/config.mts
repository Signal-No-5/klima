import { defineConfig } from "vitepress";

export default defineConfig({
  title: "Klima",
  description:
    "Weather-resilience monorepo — getting started, layout, and API overview",
  // Agent planning markdown stays in-repo but is not part of the product docs site
  // (avoids Vue parsing quirks in handoff templates, and keeps nav focused).
  srcExclude: ["mvp/**", "handoffs/**"],
  themeConfig: {
    nav: [
      { text: "Home", link: "/" },
      { text: "Getting started", link: "/getting-started" },
      { text: "Layout", link: "/layout" },
      { text: "API", link: "/api/overview" },
      { text: "Schema", link: "/schema" },
    ],
    sidebar: [
      {
        text: "Guide",
        items: [
          { text: "Home", link: "/" },
          { text: "Getting started", link: "/getting-started" },
          { text: "Monorepo layout", link: "/layout" },
        ],
      },
      {
        text: "Quickstarts",
        items: [
          { text: "Backend (API + pipeline)", link: "/guide/backend" },
          { text: "Frontend (dashboard stub)", link: "/guide/frontend" },
          { text: "Mobile (Flutter)", link: "/guide/mobile" },
          { text: "Data / ETL", link: "/guide/data" },
          { text: "Docs site", link: "/guide/docs" },
        ],
      },
      {
        text: "Reference",
        items: [
          { text: "API overview", link: "/api/overview" },
          { text: "Schema / contracts", link: "/schema" },
        ],
      },
    ],
    socialLinks: [
      { icon: "github", link: "https://github.com/Signal-No-5/klima" },
    ],
  },
});
