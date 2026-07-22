function build_canvas(c::Canvas)

    if length(c.names) > 4
        throw(ArgumentError("Use maximum 4 classes"))
    end

    if length(c.names) > length(c.colors)
        throw(ArgumentError("too many class names for colors"))
    end
    
    @htl("""
    <div class="drawdata-widget" id="canvas-widget">

        <div class="toolbar">

            <div class="classes">

             
            $((@htl("""
                <label class="class-option">
                    <input
                        type="radio"
                        name="active-class"
                        value=$(i)
                        checked=$(i == 1)
                        data-color=$( "#" * hex(c.colors[i]) )
                    >
                    <span
                        class="swatch"
                        style=$( "background: #$(hex(c.colors[i]));" )                    ></span>
                    $(c.names[i])
                </label>
                """) for i in eachindex(c.names)))
            </div>

            <label class="size-control">
                Size
                <input
                    id="size-slider"
                    type="range"
                    min="10"
                    max="50"
                    value="20"
                >
            </label>

            <button id="reset-button">
                Reset
            </button>

            <button id="download-button">
                Download CSV
            </button>

        </div>

        <canvas
            width="600"
            height="600"
        ></canvas>

        <script>
        
        const root = currentScript.closest(".drawdata-widget");
        const output = root.querySelector(".canvas-value");

        const bond = window.AbstractPlutoDingetjes.getBondValue;
        const setValue = window.AbstractPlutoDingetjes.setBondValue;
        
        const canvas = root.querySelector("canvas");
        const ctx = canvas.getContext("2d");
        
        const sizeSlider = root.querySelector("#size-slider");
        const classButtons = root.querySelectorAll('input[name="active-class"]');
        
        const reset = root.querySelector("#reset-button");
        const download = root.querySelector("#download-button");
        
        const state = {
            mouseX: null,
            mouseY: null,
            radius: Number(sizeSlider.value),
             pointRadius: 2,
            color: root.querySelector('input[name="active-class"]:checked').dataset.color,
            classIndex: Number(root.querySelector('input[name="active-class"]:checked').value),
            points: [],
            drawing: false
        };


        // Convert browser coordinates to canvas coordinates
        function canvasPosition(event) {
            const rect = canvas.getBoundingClientRect();

            return {
                x: (event.clientX - rect.left) * (canvas.width / rect.width),
                y: (event.clientY - rect.top) * (canvas.height / rect.height)
            };
        }


        // Create a cursor showing brush size
        function updateCursor() {
            const r = state.radius;

            const svg = `
            <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64">
                <circle cx="32" cy="32" r="{r}"
                    fill="none"
                    stroke="black"
                    stroke-width="1.5"/>
                <line x1="32" y1="0" x2="32" y2="64"
                    stroke="black"
                    stroke-width="1"/>
                <line x1="0" y1="32" x2="64" y2="32"
                    stroke="black"
                    stroke-width="1"/>
            </svg>`;

            canvas.style.cursor =
                `url("data:image/svg+xml,{encodeURIComponent(svg)}") 32 32, crosshair`;
        }

        function randomPointInCircle(cx, cy, radius) {
            const angle = Math.random() * 2 * Math.PI;
            const distance = Math.sqrt(Math.random()) * radius;

            return {
                x: cx + Math.cos(angle) * distance,
                y: cy + Math.sin(angle) * distance
            };
        }

        function updateBinding() {
            const value = state.points.map(p => [
                p.x_rel,
                p.y_rel,
                p.classIndex
            ]);

            root.value = value;
            root.dispatchEvent(new CustomEvent("input"));
        }     


        // Draw everything
        function draw() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // Existing points
            for (const p of state.points) {
                ctx.beginPath();
                ctx.arc(p.x, p.y, p.radius, 0, 2 * Math.PI);
                ctx.fillStyle = p.color;
                ctx.fill();
            }

            // Brush preview
            if (state.mouseX !== null) {
                ctx.beginPath();
                ctx.arc(
                    state.mouseX,
                    state.mouseY,
                    state.radius,
                    0,
                    2 * Math.PI
                );

                ctx.globalAlpha = 0.25;
                ctx.fillStyle = state.color;
                ctx.fill();

                ctx.globalAlpha = 1;
                ctx.strokeStyle = state.color;
                ctx.lineWidth = 2;
                ctx.stroke();
            }
        }


        canvas.addEventListener("mousedown", () => {
            state.drawing = true;
        });


        canvas.addEventListener("mouseup", () => {
            state.drawing = false;
        });


        canvas.addEventListener("mouseleave", () => {
            state.mouseX = null;
            state.mouseY = null;
            state.drawing = false;

            draw();
        });

        canvas.addEventListener("mousemove", (event) => {
            const pos = canvasPosition(event);

            state.mouseX = pos.x;
            state.mouseY = pos.y;

            if (state.drawing) {
                const p = randomPointInCircle(
                    state.mouseX,
                    state.mouseY,
                    state.radius
                );

                state.points.push({
                    x: p.x,
                    y: p.y,
                    x_rel: p.x/600,
                    y_rel: p.y/600,
                    radius: state.pointRadius,
                    color: state.color,
                    classIndex: state.classIndex
                });
                
                updateBinding();
            }

            draw();
        });


        // Brush size
        sizeSlider.addEventListener("input", () => {
            state.radius = Number(sizeSlider.value);

            updateCursor();
            draw();
        });


        // Class/color selection
        classButtons.forEach(button => {
            button.addEventListener("change", () => {
                if (button.checked) {
                    state.color = button.dataset.color;
                    state.classIndex = Number(button.value);
                    updateCursor();
                    draw();
                }
            });
        });

        reset.addEventListener("click", () => {
            state.points = [];
            draw();
            updateBinding();
        });

        download.addEventListener("click", () => {
            const rows = [
                ["x", "y", "class"],
                ...state.points.map(p => [
                    p.x_rel,
                    p.y_rel,
                    p.classIndex
                ])
            ];

            const csv = rows
                .map(row => row.join(","))
                .join("\\n");

            const blob = new Blob([csv], {
                type: "text/csv;charset=utf-8;"
            });

            const url = URL.createObjectURL(blob);

            const link = document.createElement("a");
            link.href = url;
            link.download = "points.csv";

            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            URL.revokeObjectURL(url);
        });


        // Initialize
        updateCursor();
        draw();
        updateBinding();
        root.value = [];
        </script>
    </div>

    <style>
    .drawdata-widget {
        display: inline-flex;
        flex-direction: column;
        border: 1px solid #ccc;
        border-radius: 6px;
        overflow: hidden;
        background: white;
    }

    .toolbar {
        display: flex;
        align-items: center;
        gap: 1rem;
        padding: .5rem .75rem;
        background: #f7f7f7;
        border-bottom: 1px solid #ddd;
        flex-wrap: wrap;
    }

    .classes {
        display: flex;
        gap: .8rem;
    }

    .class-option {
        display: flex;
        align-items: center;
        gap: .35rem;
        cursor: pointer;
        user-select: none;
    }

    .swatch {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        border: 1px solid #666;
    }

    .size-control {
        display: flex;
        align-items: center;
        gap: .5rem;
    }

    canvas {
        background: white;
        display: block;
    }
    </style>

    """)
end