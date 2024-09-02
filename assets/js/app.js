// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
import "flowbite/dist/flowbite.phoenix.js";

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let Hooks = {};

Hooks.Momentum = {
  generatePath(cx, cy, rx, ry, t1, Δ, φ, klass, style, id) {
    const cos = Math.cos;
    const sin = Math.sin;
    const π = Math.PI;

    const f_matrix_times = ([[a, b], [c, d]], [x, y]) => [
      a * x + b * y,
      c * x + d * y,
    ];
    const f_rotate_matrix = (x) => [
      [cos(x), -sin(x)],
      [sin(x), cos(x)],
    ];
    const f_vec_add = ([a1, a2], [b1, b2]) => [a1 + b1, a2 + b2];

    const toRadian = (x) => (x / 180) * π;

    t1 = toRadian(t1);
    Δ = toRadian(Δ);
    φ = toRadian(φ);

    /*
    returns a SVG path element that represent a ellipse.
    cx,cy → center of ellipse
    rx,ry → major minor radius
    t1 → start angle, in radian.
    Δ → angle to sweep, in radian. positive.
    φ → rotation on the whole, in radian
    */
    Δ = Δ % (2 * π);
    const rotMatrix = f_rotate_matrix(φ);
    const [sX, sY] = f_vec_add(
      f_matrix_times(rotMatrix, [rx * cos(t1), ry * sin(t1)]),
      [cx, cy],
    );
    const [eX, eY] = f_vec_add(
      f_matrix_times(rotMatrix, [rx * cos(t1 + Δ), ry * sin(t1 + Δ)]),
      [cx, cy],
    );
    const fA = Δ > π ? 1 : 0;
    const fS = Δ > 0 ? 1 : 0;
    const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
    path.setAttribute(
      "d",
      "M " +
        sX +
        " " +
        sY +
        " A " +
        [rx, ry, (φ / (2 * π)) * 360, fA, fS, eX, eY].join(" "),
    );
    path.setAttribute("class", klass);
    path.setAttribute("style", style);
    path.setAttribute("id", id);
    return path;
  },

  generateTextPath(x, y, txt, href, dy, startOffset, klass) {
    var text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    var path = document.createElementNS(
      "http://www.w3.org/2000/svg",
      "textPath",
    );
    path.textContent = txt;
    path.setAttributeNS(null, "href", href);
    path.setAttributeNS(null, "startOffset", startOffset);

    text.setAttributeNS(null, "class", klass);
    text.setAttributeNS(null, "text-anchor", "middle");
    text.setAttributeNS(null, "dy", dy);
    text.replaceChildren(path);

    return text;
  },

  generateText(x, y, txt, fontSize) {
    var text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    text.textContent = txt;
    text.setAttributeNS(null, "x", x);
    text.setAttributeNS(null, "y", y);
    text.setAttributeNS(null, "font-size", fontSize);
    text.setAttributeNS(null, "dominant-baseline", "middle");
    text.setAttributeNS(null, "text-anchor", "middle");

    return text;
  },

  generateTextSpan(parent, x, y, txt, fontSize) {
    var text = document.createElementNS("http://www.w3.org/2000/svg", "tspan");
    text.textContent = txt;
    text.setAttributeNS(null, "x", x);
    text.setAttributeNS(null, "y", y);
    text.setAttributeNS(null, "font-size", fontSize);
    text.setAttributeNS(null, "dominant-baseline", "middle");
    text.setAttributeNS(null, "text-anchor", "middle");
    text.setAttributeNS(null, "class", "fill-green-500");

    parent.appendChild(text);
    return parent;
  },

  generateCircle(r, cy, cx, klass) {
    var circle = document.createElementNS(
      "http://www.w3.org/2000/svg",
      "circle",
    );
    circle.setAttributeNS(null, "r", r);
    circle.setAttributeNS(null, "cy", cy);
    circle.setAttributeNS(null, "cx", cx);
    circle.setAttributeNS(null, "class", klass);

    return circle;
  },

  generate1() {
    path = this.generatePath(
      101,
      101,
      85,
      85,
      75,
      150,
      90,
      "stroke-green-500 fill-none stroke-[20px]",
      "stroke-linecap: round",
    );

    path2 = this.generatePath(
      101,
      101,
      85,
      85,
      75,
      210,
      90,
      "stroke-slate-300 fill-none stroke-[11px]",
      "stroke-linecap: round",
    );

    path3 = this.generatePath(
      101,
      101,
      85,
      85,
      179,
      45,
      90,
      "stroke-green-300 fill-none stroke-[11px]",
      "stroke-linecap: round",
      "diff",
    );
    text3 = this.generateTextPath(0, 0, "+ 23 %", "#diff", `25px`);
    text3.setAttributeNS(null, "font-size", "15px");
    text3.setAttributeNS(null, "class", "fill-green-500");

    path4 = this.generatePath(
      101,
      101,
      85,
      85,
      175,
      2,
      90,
      "stroke-yellow-300 fill-none stroke-[30px]",
    );

    angleDiff = 200 / 6;
    path01 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + angleDiff,
      angleDiff - 2,
      90,
      "stroke-green-200 fill-none stroke-[25px]",
      "",
      "monday",
    );
    text01 = this.generateTextPath(0, 0, "Пн", "#monday", `-20px`);

    path011 = this.generatePath(
      101,
      101,
      112,
      112,
      30 + 2 + angleDiff,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );
    path012 = this.generatePath(
      101,
      101,
      119,
      119,
      30 + 2 + angleDiff,
      angleDiff - 2 - 4,
      90,
      "stroke-red-400 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path013 = this.generatePath(
      101,
      101,
      126,
      126,
      30 + 2 + angleDiff,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path02 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + angleDiff * 2,
      angleDiff - 2,
      90,
      "stroke-red-200 fill-none stroke-[10px]",
      "",
      "tuesday",
    );

    text02 = this.generateTextPath(0, 0, "Вт", "#tuesday", `-10px`);

    path021 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + 2 + angleDiff * 2,
      angleDiff - 2 - 4,
      90,
      "stroke-red-400 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path03 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + angleDiff * 3,
      angleDiff - 2,
      90,
      "stroke-green-200 fill-none stroke-[35px]",
      "",
      "wednesday",
    );

    text03 = this.generateTextPath(0, 0, "Ср", "#wednesday", `-25px`);

    path031 = this.generatePath(
      101,
      101,
      110,
      110,
      30 + 2 + angleDiff * 3,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path032 = this.generatePath(
      101,
      101,
      117,
      117,
      30 + 2 + angleDiff * 3,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );
    path033 = this.generatePath(
      101,
      101,
      125,
      125,
      30 + 2 + angleDiff * 3,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );
    path034 = this.generatePath(
      101,
      101,
      132,
      132,
      30 + 2 + angleDiff * 3,
      angleDiff - 2 - 4,
      90,
      "stroke-red-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path04 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + angleDiff * 4,
      angleDiff - 2,
      90,
      "stroke-green-200 fill-none stroke-[25px]",
      "",
      "thursday",
    );

    text04 = this.generateTextPath(0, 0, "Чт", "#thursday", `-20px`);

    path041 = this.generatePath(
      101,
      101,
      113,
      114,
      30 + 2 + angleDiff * 4,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );
    path042 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + 2 + angleDiff * 4,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );
    path043 = this.generatePath(
      101,
      101,
      127,
      127,
      30 + 2 + angleDiff * 4,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path05 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + angleDiff * 5,
      angleDiff - 2,
      90,
      "stroke-red-200 fill-none stroke-[20px]",
      "",
      "friday",
    );
    text05 = this.generateTextPath(0, 0, "Пт", "#friday", `-15px`);

    path051 = this.generatePath(
      101,
      101,
      117,
      117,
      30 + 2 + angleDiff * 5,
      angleDiff - 2 - 4,
      90,
      "stroke-red-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path052 = this.generatePath(
      101,
      101,
      124,
      124,
      30 + 2 + angleDiff * 5,
      angleDiff - 2 - 4,
      90,
      "stroke-red-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path06 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + angleDiff * 6,
      angleDiff - 2,
      90,
      "stroke-green-200 fill-none stroke-[25px]",
      "",
      "saturday",
    );

    text06 = this.generateTextPath(0, 0, "Сб", "#saturday", `-20px`);

    path061 = this.generatePath(
      101,
      101,
      113,
      113,
      30 + 2 + angleDiff * 6,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path062 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + 2 + angleDiff * 6,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path063 = this.generatePath(
      101,
      101,
      127,
      127,
      30 + 2 + angleDiff * 6,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[5px]",
      "stroke-linecap: round",
    );

    path07 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + angleDiff * 7,
      angleDiff - 2,
      90,
      "stroke-slate-200 fill-none stroke-[10px]",
      "",
      "sunday",
    );
    text07 = this.generateTextPath(0, 0, "Вс", "#sunday", `-20px`);
    path071 = this.generatePath(
      101,
      101,
      120,
      120,
      30 + 2 + angleDiff * 7,
      angleDiff - 2 - 4,
      90,
      "stroke-green-500 fill-none stroke-[1px] hidden",
      "stroke-linecap: round",
    );
    totalLength = path071.getTotalLength();

    textMainPercentage = this.generateText("50%", "70%", "72%", "3em");

    this.el
      .querySelector("svg")
      .replaceChildren(
        path2,
        path,
        path3,
        path4,
        text3,
        path01,
        path011,
        path012,
        path013,
        text01,
        path02,
        path021,
        text02,
        path03,
        path031,
        path032,
        path033,
        path034,
        text03,
        path04,
        text04,
        path05,
        path051,
        path052,
        text05,
        path06,
        text06,
        path07,
        text07,
        path071,
        textMainPercentage,
      );
  },
  generateRectangleWithText(
    x,
    y,
    w,
    h,
    textX,
    textY,
    txt,
    rectClass,
    textClass,
  ) {
    var g = document.createElementNS("http://www.w3.org/2000/svg", "g");
    var text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    var rectangle = document.createElementNS(
      "http://www.w3.org/2000/svg",
      "rect",
    );

    rectangle.setAttributeNS(null, "x", x);
    rectangle.setAttributeNS(null, "y", y);
    rectangle.setAttributeNS(null, "width", w);
    rectangle.setAttributeNS(null, "height", h);
    rectangle.setAttributeNS(null, "class", rectClass);
    rectangle.setAttributeNS(null, "rx", "15");

    text.setAttributeNS(null, "class", textClass);
    text.setAttributeNS(null, "text-anchor", "middle");
    text.setAttributeNS(null, "x", textX);
    text.setAttributeNS(null, "y", textY);
    text.textContent = txt;

    g.replaceChildren(rectangle, text);

    return g;
  },
  radiusModifier(maximumTasks) {
    switch (true) {
      case maximumTasks < 5:
        return 1.2;
      case maximumTasks < 6:
        return 1.15;
      case maximumTasks < 7:
        return 1.1;
      default:
        return 1;
    }
  },
  generateMomentum(momentum) {
    radiusModifier = this.radiusModifier(momentum.maximum_tasks_in_a_day);

    allElements = [];

    startAngle = 180;
    angleDiff = 180 / 7;
    blockWidth = angleDiff;

    path01 = this.generatePath(
      101,
      101,
      95 * radiusModifier,
      95 * radiusModifier,
      180,
      180,
      0,
      "stroke-green-200 fill-none stroke-[5px] hidden",
      "",
      `weekdays-${momentum.id}`,
    );
    allElements.push(path01);

    offsetInc = 100 / 7;
    weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"];

    for (let i = 0; i < 7; i++) {
      allElements.push(
        this.generateTextPath(
          0,
          0,
          weekdays[i],
          `#weekdays-${momentum.id}`,
          `0px`,
          `${offsetInc * i + angleDiff / 5 + 2}%`,
          "fill-gray-400 text-sm",
        ),
      );
    }

    for (let i = 0; i < 7; i++) {
      window.tasks = momentum.tasks_by_days;
      tasks = momentum.tasks_by_days[i + 1];

      if (tasks.length) {
        tasks.forEach((task, index) => {
          let color = ((status) => {
            switch (status) {
              case "pending":
                return "stroke-yellow-300";
              case "completed":
                return "stroke-green-500";
              case "failed":
                return "stroke-red-500";
            }
          })(task.status);

          allElements.push(
            this.generatePath(
              101,
              101,
              (115 + 7 * index) * radiusModifier,
              (115 + 7 * index) * radiusModifier,
              180 + 2 + angleDiff * i,
              blockWidth - 4,
              0,
              `${color} fill-none stroke-[4px]`,
              "stroke-linecap: round",
            ),
          );
        });
      } else {
        allElements.push(
          this.generatePath(
            101,
            101,
            115 * radiusModifier,
            115 * radiusModifier,
            180 + 1 + angleDiff * i,
            blockWidth - 2,
            0,
            `stroke-gray-300 fill-none stroke-[2px]`,
          ),
        );
      }
    }

    textMainPercentage = this.generateText(
      "50%",
      "25%",
      `${momentum.value_at_end}%`,
      "30px",
    );
    textMomentum = this.generateText("50%", "40%", "Стабильность", "20px");
    allElements.push(textMainPercentage);
    allElements.push(textMomentum);

    valueDiff = momentum.value_at_end - momentum.value_at_start;
    diffSign = valueDiff < 0 ? "-" : "+";
    diffText = `${diffSign} ${Math.abs(valueDiff)}% в этом цикле`;
    diffColor = valueDiff < 0 ? "fill-purple-200" : "fill-cyan-200";

    allElements.push(
      this.generateRectangleWithText(
        200 / 2 - 140 / 2,
        "50%",
        "140",
        "35",
        "50%",
        "65%",
        diffText,
        diffColor,
        "text-sm",
      ),
    );

    this.el.querySelector("svg").replaceChildren(...allElements);
  },

  mounted() {
    this.handleEvent(`init_${this.el.id}`, (momentum) => {
      this.generateMomentum(momentum);
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (info) => {
  topbar.hide();

  if (info.detail.kind === "initial") {
    window.Telegram.WebApp.ready();
  }
  if (window.Telegram) {
    if (window.previousHandler) {
      window.Telegram.WebApp.BackButton.offClick(window.previousHandler);
    }

    backButtons = document.querySelectorAll(".tg-back-button");
    console.log(backButtons);
    if (backButtons.length) {
      lastButton = backButtons[backButtons.length - 1];

      window.Telegram.WebApp.BackButton.show();
      window.previousHandler = () => {
        liveSocket.execJS(lastButton, lastButton.getAttribute("data-navigate"));
      };
      window.Telegram.WebApp.BackButton.onClick(previousHandler);
    } else {
      window.Telegram.WebApp.BackButton.hide();
    }
  }
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

window.onload = (event) => {
  window.Telegram.WebApp.expand();
  window.Telegram.WebApp.disableVerticalSwipes();

  window.Telegram.WebApp.SettingsButton.onClick(() => {
    settingsButton = document.querySelector(".tg-settings-button");
    res = window.liveSocket.execJS(
      settingsButton,
      settingsButton.getAttribute("data-navigate"),
    );
  });
  window.Telegram.WebApp.SettingsButton.show();
};
