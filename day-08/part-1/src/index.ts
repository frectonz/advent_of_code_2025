function calcDistance(
	x1: number,
	y1: number,
	z1: number,
	x2: number,
	y2: number,
	z2: number,
): number {
	const dx = x2 - x1;
	const dy = y2 - y1;
	const dz = z2 - z1;
	return dx * dx + dy * dy + dz * dz;
}

async function main() {
	const file = Bun.file("inputs/example.txt");
	const input = (await file.text()).trim();

	const positions = input
		.split("\n")
		.map((x) => x.split(",").map((x) => parseInt(x)));

	const circuits: Record<string, [number, number, number][]> = {};

	for (const [x, y, z] of positions) {
		const key = `${x}:${y}:${z}`;
		circuits[key] = [[x!, y!, z!]];
	}

	let step = 0;
	const circuitKeys = Object.keys(circuits);

	while (step < 10) {
		console.log("connection", step);

		let minDistance = Infinity;
		let minJunction:
			| [[number, number, number], [number, number, number]]
			| null = null;

		for (const key1 of circuitKeys) {
			const [x1, y1, z1] = circuits[key1]![0]!;
			const values = circuits[key1]!;

			for (const key2 of circuitKeys) {
				const [x2, y2, z2] = circuits[key2]![0]!;

				if (x1 == x2 && y1 == y2 && z1 == z2) continue;
				if (values.find(([x, y, z]) => x == x2 && y == y2 && z == z2)) continue;

				const distance = calcDistance(x1!, y1!, z1!, x2!, y2!, z2!);

				if (distance < minDistance) {
					minDistance = distance;
					minJunction = [
						[x1!, y1!, z1!],
						[x2!, y2!, z2!],
					];
				}
			}
		}

		const [[x1, y1, z1], [x2, y2, z2]] = minJunction!;

		const key1 = `${x1}:${y1}:${z1}`;
		const key2 = `${x2}:${y2}:${z2}`;

		const values1 = circuits[key1]!;
		values1.push([x2, y2, z2]);
		for (const val of values1) {
			const values = circuits[val.join(":")]!;

			const contains = values.find(
				([x, y, z]) => x == x2 && y == y2 && z == z2,
			);

			if (!contains) values.push([x2, y2, z2]);
		}

		const values2 = circuits[key2]!;
		values2.push([x1, y1, z1]);
		for (const val of values2) {
			const values = circuits[val.join(":")]!;

			const contains = values.find(
				([x, y, z]) => x == x1 && y == y1 && z == z1,
			);

			if (!contains) values.push([x1, y1, z1]);
		}

		step++;
	}

	for (const pos of positions) {
		const allCircuits = Object.entries(circuits);

		const [x, y, z] = pos;

		const containedIn = allCircuits
			.filter(([_, circuit]) =>
				circuit.find(([x1, y1, z1]) => x == x1 && y == y1 && z == z1),
			)
			.toSorted(([_, a], [__, b]) => a.length - b.length)
			.map(([key, _]) => key);

		delete containedIn[containedIn.length - 1];

		for (const node of containedIn) {
			delete circuits[node];
		}
	}

	const counts = Object.values(circuits)
		.map((x) => x.length)
		.toSorted((a, b) => b - a);
	const result = counts[0]! * counts[1]! * counts[2]!;
	console.log(result);
}

main();
