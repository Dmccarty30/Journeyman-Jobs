import { config } from "./config.js";
const TWENTY_FIRST_API_KEY = config.apiKey || process.env.TWENTY_FIRST_API_KEY || process.env.API_KEY;
const isTesting = process.env.DEBUG === "true" ? true : false;
export const BASE_URL = isTesting
    ? "http://localhost:3005"
    : "https://magic.21st.dev";
const createMethod = (method) => {
    return async (endpoint, data, options = {}) => {
        const headers = {
            "Content-Type": "application/json",
            ...(TWENTY_FIRST_API_KEY ? { "x-api-key": TWENTY_FIRST_API_KEY } : {}),
            ...options.headers,
        };
        console.log("BASE_URL", BASE_URL);
        const response = await fetch(`${BASE_URL}${endpoint}`, {
            ...options,
            method,
            headers,
            ...(data ? { body: JSON.stringify(data) } : {}),
        });
        console.log("response", response);
        return { status: response.status, data: (await response.json()) };
    };
};
export const twentyFirstClient = {
    get: createMethod("GET"),
    post: createMethod("POST"),
    put: createMethod("PUT"),
    delete: createMethod("DELETE"),
    patch: createMethod("PATCH"),
};
