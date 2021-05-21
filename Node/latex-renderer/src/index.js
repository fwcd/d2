const sharp = require("sharp");
const yargs = require("yargs/yargs");
const { hideBin } = require("yargs/helpers");

const argv = yargs(hideBin(process.argv))
    .demand(1)
    .usage("$0 [math]")
    .strict()
    .option("color", {
        description: "The LaTeX color to wrap the input in",
        default: "white"
    })
    .option("scale", {
        type: "number",
        description: "The scale of the output (only applies to PNG output)",
        default: 1
    })
    .option("svg", {
        description: "Output SVG instead of (binary) PNG data"
    })
    .argv;

(async () => {
    try {
        const math = argv._[0];
        const mathjax = await require("mathjax-full").init({
            loader: {
                load: ["input/tex", "output/svg"]
            }
        });

        const adaptor = mathjax.startup.adaptor;
        const svgNode = await mathjax.tex2svgPromise(`\\color{${argv.color}}{${math}}`, {
            display: true
        });
        const svgString = adaptor.innerHTML(svgNode);

        if (argv.svg) {
            process.stdout.write(`${svgString}\n`);
        } else {
            const svgBuffer = Buffer.from(svgString, "utf8");
            const pngBuffer = await sharp(svgBuffer, { density: argv.scale * 100 }).png().toBuffer();
            process.stdout.write(pngBuffer);
        }
    } catch (e) {
        console.log("Error: " + e);
    }
})();
