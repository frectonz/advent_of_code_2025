async function main() {
	const file = Bun.file("inputs/example.txt");
	const input = await file.text();
}

main()
