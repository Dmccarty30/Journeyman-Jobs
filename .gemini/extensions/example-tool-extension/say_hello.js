const name = JSON.parse(process.stdin.read()).name;
console.log(JSON.stringify({ output: `Hello, ${name}!` }));