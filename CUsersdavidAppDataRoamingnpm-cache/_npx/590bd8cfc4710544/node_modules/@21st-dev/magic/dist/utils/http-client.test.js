import { BASE_URL } from "./http-client.js";
describe("http-client", () => {
    it("should use production URL in production environment", () => {
        expect(BASE_URL).toBe("https://magic.21st.dev");
    });
});
