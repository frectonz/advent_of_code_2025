class UnionFind {
	par: number[];
	size: number[];

	constructor(n: number) {
		this.par = Array.from({ length: n }, (_, i) => i);
		this.size = Array(n).fill(1);
	}

	find(x: number): number {
		while (this.par[x] !== x) {
			this.par[x] = this.par[this.par[x]!]!;
			x = this.par[x]!;
		}
		return x;
	}

	union(x: number, y: number): boolean {
		const parX = this.find(x);
		const parY = this.find(y);

		if (parX === parY) return false;

		if (this.size[parX]! >= this.size[parY]!) {
			this.par[parY] = parX;
			this.size[parX]! += this.size[parY]!;
		} else {
			this.par[parX] = parY;
			this.size[parY]! += this.size[parX]!;
		}

		return true;
	}
}

type Pos = { x: number; y: number; z: number };

function getDist(first: Pos, second: Pos): number {
	const { x: x1, y: y1, z: z1 } = first;
	const { x: x2, y: y2, z: z2 } = second;

	const dx = x1 - x2;
	const dy = y1 - y2;
	const dz = z1 - z2;

	return dx * dx + dy * dy + dz * dz;
}

async function main() {
	const text = await Bun.file("inputs/input.txt").text();
	const lines = text.trim().split(/\r?\n/).filter(Boolean);

	const coordinates: Pos[] = lines.map((line) => {
		const [x, y, z] = line
			.trim()
			.split(",")
			.map((v) => parseInt(v, 10));
		return { x: x!, y: y!, z: z! };
	});

	const n = coordinates.length;
	const distances: [number, number, number][] = [];

	for (let i = 0; i < n; i++) {
		for (let j = i + 1; j < n; j++) {
			const currDist = getDist(coordinates[i]!, coordinates[j]!);
			distances.push([currDist, i, j]);
		}
	}

	const uf = new UnionFind(n);
	distances.sort((a, b) => a[0] - b[0]);

	const limit = 1000;
	const len = Math.min(distances.length, limit);

	for (let i = 0; i < len; i++) {
		const [, firstInd, secondInd] = distances[i]!;
		uf.union(firstInd, secondInd);
	}

	const sortedComp = [...uf.size].sort((a, b) => b - a);
	const [x, y, z] = sortedComp;

	console.log(x! * y! * z!);
}

main();
