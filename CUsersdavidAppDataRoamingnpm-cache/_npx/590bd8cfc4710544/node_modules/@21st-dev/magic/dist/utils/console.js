// Override console for Cursor's error handling
const originalConsoleLog = console.log;
const originalConsoleError = console.error;
export function setupJsonConsole() {
    console.log = function (...args) {
        const message = args
            .map((arg) => {
            if (typeof arg === "object" || Array.isArray(arg)) {
                try {
                    return JSON.stringify(arg);
                }
                catch (e) {
                    return String(arg);
                }
            }
            return String(arg);
        })
            .join(" ");
        originalConsoleLog(JSON.stringify({
            jsonrpc: "2.0",
            method: "window/logMessage",
            params: {
                type: 3,
                message: message,
            },
        }));
    };
    console.error = function (...args) {
        const message = args
            .map((arg) => {
            if (typeof arg === "object" || Array.isArray(arg)) {
                try {
                    return JSON.stringify(arg);
                }
                catch (e) {
                    return String(arg);
                }
            }
            return String(arg);
        })
            .join(" ");
        originalConsoleError(JSON.stringify({
            jsonrpc: "2.0",
            method: "window/logMessage",
            params: {
                type: 1,
                message: message,
            },
        }));
    };
}
