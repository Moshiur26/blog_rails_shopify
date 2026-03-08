import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "@/App";
import "@/styles/application.css";

const rootElement = document.getElementById("react-root");

if (rootElement) {
  const bootstrap = JSON.parse(rootElement.dataset.bootstrap || "{}");

  createRoot(rootElement).render(
    <StrictMode>
      <App bootstrap={bootstrap} />
    </StrictMode>
  );
}
