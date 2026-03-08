export async function apiGet(path, token) {
  const headers = {
    "Content-Type": "application/json"
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(path, { headers });

  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }

  return response;
}
