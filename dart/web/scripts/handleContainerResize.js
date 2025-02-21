const handle = document.getElementById("resize-handle");
const textarea = document.getElementById("input");
const canvasContainer = document.querySelector(".canvas-container");
const canvas = document.getElementById("output");

let isResizing = false;

handle.addEventListener("mousedown", (e) => {
    isResizing = true;
    document.addEventListener("mousemove", onMouseMove);
    document.addEventListener("mouseup", () => {
        isResizing = false;
        document.removeEventListener("mousemove", onMouseMove);
    });
});

function onMouseMove(e) {
    if (!isResizing) return;
    let newWidth = e.clientX;
    textarea.style.flex = `0 0 ${newWidth}px`;
    canvasContainer.style.flex = `1`;
}