function withEmbeddedQuery(path) {
  const query = window.location.search;
  if (!query) return path;
  return path.includes("?") ? `${path}&${query.slice(1)}` : `${path}${query}`;
}

export async function apiGet(path) {
  const response = await fetch(withEmbeddedQuery(path), {
    headers: {
      "Content-Type": "application/json"
    }
  });

  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }

  return response;
}
