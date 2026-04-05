import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import ProductsPage from "@/pages/ProductsPage";
import "@/styles/application.css";

const rootElement = document.getElementById("react-root");

if (rootElement) {
  const bootstrap = JSON.parse(rootElement.dataset.bootstrap || "{}");

  createRoot(rootElement).render(
    <StrictMode>
      <ProductsPage bootstrap={bootstrap} />
    </StrictMode>
  );
}
