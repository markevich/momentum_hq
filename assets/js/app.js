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
import { gsap } from "gsap";
import { TextPlugin } from "gsap/TextPlugin";
gsap.registerPlugin(TextPlugin);

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

  generateText(x, y, txt, fontSize, klass) {
    var text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    text.textContent = txt;
    text.setAttributeNS(null, "x", x);
    text.setAttributeNS(null, "y", y);
    text.setAttributeNS(null, "font-size", fontSize);
    text.setAttributeNS(null, "dominant-baseline", "middle");
    text.setAttributeNS(null, "text-anchor", "middle");
    text.setAttributeNS(null, "class", klass);

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
  generateGroup(klass) {
    var g = document.createElementNS("http://www.w3.org/2000/svg", "g");
    g.setAttributeNS(null, "class", klass);
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
    let momentumGroup = this.generateGroup();
    radiusModifier = this.radiusModifier(momentum.maximum_tasks_in_a_day);

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
    momentumGroup.appendChild(path01);

    offsetInc = 100 / 7;
    weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"];

    for (let i = 0; i < 7; i++) {
      momentumGroup.appendChild(
        this.generateTextPath(
          0,
          0,
          weekdays[i],
          `#weekdays-${momentum.id}`,
          `0px`,
          `${offsetInc * i + angleDiff / 5 + 2}%`,
          "fill-gray-400 text-sm weekdays",
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

          momentumGroup.appendChild(
            this.generatePath(
              101,
              101,
              (115 + 7 * index) * radiusModifier,
              (115 + 7 * index) * radiusModifier,
              180 + 2 + angleDiff * i,
              blockWidth - 4,
              0,
              `task-svg ${color} fill-none stroke-[4px]`,
              "stroke-linecap: round",
            ),
          );
        });
      } else {
        momentumGroup.appendChild(
          this.generatePath(
            101,
            101,
            115 * radiusModifier,
            115 * radiusModifier,
            180 + 1 + angleDiff * i,
            blockWidth - 2,
            0,
            `task-svg stroke-gray-300 fill-none stroke-[2px]`,
          ),
        );
      }
    }

    textMainPercentage = this.generateText(
      "50%",
      "25%",
      `${momentum.value_at_end}%`,
      "30px",
      "text-main",
    );
    textMomentum = this.generateText(
      "50%",
      "40%",
      "Стабильность",
      "20px",
      "text-main",
    );
    momentumGroup.appendChild(textMainPercentage);
    momentumGroup.appendChild(textMomentum);

    valueDiff = momentum.value_at_end - momentum.value_at_start;
    diffSign = valueDiff < 0 ? "-" : "+";
    diffText = `${diffSign} ${Math.abs(valueDiff)}% в этом цикле`;
    diffColor = valueDiff < 0 ? "fill-purple-200" : "fill-cyan-200";

    momentumGroup.appendChild(
      this.generateRectangleWithText(
        200 / 2 - 140 / 2,
        "50%",
        "140",
        "35",
        "50%",
        "65%",
        diffText,
        `diff-rect ${diffColor}`,
        "diff-text text-sm",
      ),
    );

    this.el.querySelector("svg").replaceChildren(momentumGroup);
    window.gsap = gsap;
  },

  mounted() {
    this.handleEvent(`init_${this.el.id}`, (momentum) => {
      this.generateMomentum(momentum);
      var tl = gsap.timeline();

      tl.from(`.momentum-${momentum.id} .momentum-name`, {
        opacity: 0,
        y: -50,
        ease: "power2.inOut",
        delay: 0.1,
      });

      tl.from(
        `.momentum-${momentum.id} .cycle-number`,
        {
          opacity: 0,
          x: -50,
          ease: "power2.inOut",
        },
        "<",
      );
      tl.from(
        `.momentum-${momentum.id} .cycle-dates`,
        {
          opacity: 0,
          x: 50,
          ease: "power2.inOut",
        },
        "<",
      );

      tl.from(
        `.momentum-${momentum.id} .task-svg`,
        {
          scale: 0,
          transformOrigin: "50% 50%",
          stagger: { each: 0.06, from: "random" },
          ease: "power1.inOut",
        },
        ">",
      );

      tl.from(
        `.momentum-${momentum.id} .text-main`,
        {
          text: "",
          duration: 1,
          ease: "power1.inOut",
        },
        "<",
      );

      tl.from(
        `.momentum-${momentum.id} .weekdays`,
        {
          scale: 0,
          ease: "power1.inOut",
          duration: 0.5,
        },
        ">",
      );

      tl.from(
        `.momentum-${momentum.id} .diff-rect`,
        {
          scaleX: "0.02",
          transformOrigin: "50% 50%",
          ease: "power1.inOut",
          duration: 0.5,
        },
        ">",
      );

      tl.from(
        `.momentum-${momentum.id} .diff-text`,
        {
          text: "",
          ease: "power1.inOut",
        },
        "<",
      );

      tl.from(
        `.momentum-${momentum.id} .counters`,
        {
          text: "",
          ease: "power1.inOut",
        },
        ">",
      );
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
