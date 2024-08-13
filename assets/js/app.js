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
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

Hooks.Momentum = {
  generatePath(
    cx, cy,
    rx, ry,
    t1,
    Δ,
    φ,
    klass,
    style,
    id
  ){
    const cos = Math.cos;
    const sin = Math.sin;
    const π = Math.PI;
    
    const f_matrix_times = (( [[a,b], [c,d]], [x,y]) => [ a * x + b * y, c * x + d * y]);
    const f_rotate_matrix = (x => [[cos(x),-sin(x)], [sin(x), cos(x)]]);
    const f_vec_add = (([a1, a2], [b1, b2]) => [a1 + b1, a2 + b2]);
    
    const toRadian = (x) => x / 180 * π;

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
    Δ = Δ % (2*π);
    const rotMatrix = f_rotate_matrix (φ);
    const [sX, sY] = ( f_vec_add ( f_matrix_times ( rotMatrix, [rx * cos(t1), ry * sin(t1)] ), [cx,cy] ) );
    const [eX, eY] = ( f_vec_add ( f_matrix_times ( rotMatrix, [rx * cos(t1+Δ), ry * sin(t1+Δ)] ), [cx,cy] ) );
    const fA = ( (  Δ > π ) ? 1 : 0 );
    const fS = ( (  Δ > 0 ) ? 1 : 0 );
    const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
    path.setAttribute("d", "M " + sX + " " + sY + " A " + [ rx , ry , φ / (2*π) *360, fA, fS, eX, eY ].join(" "));
    path.setAttribute("class", klass)
    path.setAttribute("style", style)
    path.setAttribute("id", id)
    return path;
  },

  generateTextPath(x, y, txt, href, offset){
    var text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    var path = document.createElementNS("http://www.w3.org/2000/svg", "textPath");
    path.textContent = txt;
    path.setAttributeNS(null, 'href', href);
    path.setAttributeNS(null, 'startOffset', "50%");

    text.setAttributeNS(null, "text-anchor", "middle")
    text.setAttributeNS(null, "dy", offset)
    text.replaceChildren(path)

    return text;
  },

  generateText(x, y, txt, fontSize){
    var text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    text.textContent = txt
    text.setAttributeNS(null, "x", x)
    text.setAttributeNS(null, "y", y)
    text.setAttributeNS(null, "font-size", fontSize)
    text.setAttributeNS(null, "dominant-baseline", "middle")
    text.setAttributeNS(null, "text-anchor", "middle")

    return text;
  },

  generateTextSpan(parent, x, y, txt, fontSize){
    var text = document.createElementNS("http://www.w3.org/2000/svg", "tspan");
    text.textContent = txt
    text.setAttributeNS(null, "x", x)
    text.setAttributeNS(null, "y", y)
    text.setAttributeNS(null, "font-size", fontSize)
    text.setAttributeNS(null, "dominant-baseline", "middle")
    text.setAttributeNS(null, "text-anchor", "middle")
    text.setAttributeNS(null, "class", "fill-green-500")

    parent.appendChild(text)
    return parent;
  },

  generateCircle(r, cy, cx, klass){
    var circle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
    circle.setAttributeNS(null, "r", r)
    circle.setAttributeNS(null, "cy", cy)
    circle.setAttributeNS(null, "cx", cx)
    circle.setAttributeNS(null, "class", klass)

    return circle;
  },

  generate1(){
        path = this.generatePath(
          101, 101,
          85, 85,
          75, 150,
          90,
          "stroke-green-500 fill-none stroke-[20px]",
          "stroke-linecap: round"
        )
      
        path2 = this.generatePath(
          101, 101,
          85, 85,
          75, 210,
          90,
          "stroke-slate-300 fill-none stroke-[11px]",
          "stroke-linecap: round"
        )

        path3 = this.generatePath(
          101, 101,
          85, 85,
          179, 45,
          90,
          "stroke-green-300 fill-none stroke-[11px]",
          "stroke-linecap: round",
          "diff"
        )
        text3 = this.generateTextPath(0, 0, "+ 23 %", "#diff", `25px`)
        text3.setAttributeNS(null, "font-size", "15px")
        text3.setAttributeNS(null, "class", "fill-green-500")

        path4 = this.generatePath(
          101, 101,
          85, 85,
          175, 2,
          90,
          "stroke-yellow-300 fill-none stroke-[30px]",
        )


        angleDiff = (200 / 6)
        path01 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff, angleDiff - 2,
          90,
          "stroke-green-200 fill-none stroke-[25px]",
          "",
          "monday"
        )
        text01 = this.generateTextPath(0, 0, "Пн", "#monday", `-20px`)

        path011 = this.generatePath(
          101, 101,
          112, 112,
          30 + 2 + angleDiff, angleDiff - 2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )
        path012 = this.generatePath(
          101, 101,
          119, 119,
          30 + 2 + angleDiff, angleDiff - 2 - 4,
          90,
          "stroke-red-400 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )

        path013 = this.generatePath(
          101, 101,
          126, 126,
          30 + 2 + angleDiff, angleDiff - 2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )


        path02 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 2, angleDiff - 2,
          90,
          "stroke-red-200 fill-none stroke-[10px]",
          "",
          "tuesday"
        )

        text02 = this.generateTextPath(0, 0, "Вт", "#tuesday", `-10px`)

        path021 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 2, angleDiff - 2 - 4,
          90,
          "stroke-red-400 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )

        path03 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 3, angleDiff -2,
          90,
          "stroke-green-200 fill-none stroke-[35px]",
          "",
          "wednesday"
        )

        text03 = this.generateTextPath(0, 0, "Ср", "#wednesday", `-25px`)

        path031 = this.generatePath(
          101, 101,
          110, 110,
          30 + 2 + angleDiff * 3, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )

        path032 = this.generatePath(
          101, 101,
          117, 117,
          30 + 2 + angleDiff * 3, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )
        path033 = this.generatePath(
          101, 101,
          125, 125,
          30 + 2 + angleDiff * 3, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )
        path034 = this.generatePath(
          101, 101,
          132, 132,
          30 + 2 + angleDiff * 3, angleDiff -2 - 4,
          90,
          "stroke-red-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )


        path04 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 4, angleDiff -2,
          90,
          "stroke-green-200 fill-none stroke-[25px]",
          "",
          "thursday"
        )

        text04 = this.generateTextPath(0, 0, "Чт", "#thursday", `-20px`)

        path041 = this.generatePath(
          101, 101,
          113, 114,
          30 + 2 + angleDiff * 4, angleDiff - 2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )
        path042 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 4, angleDiff - 2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )
        path043 = this.generatePath(
          101, 101,
          127, 127,
          30 + 2 + angleDiff * 4, angleDiff - 2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )

        path05 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 5, angleDiff -2,
          90,
          "stroke-red-200 fill-none stroke-[20px]",
          "",
          "friday"
        )
        text05 = this.generateTextPath(0, 0, "Пт", "#friday", `-15px`)

        path051 = this.generatePath(
          101, 101,
          117, 117,
          30 + 2 + angleDiff * 5, angleDiff -2 - 4,
          90,
          "stroke-red-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )

        path052 = this.generatePath(
          101, 101,
          124, 124,
          30 + 2 + angleDiff * 5, angleDiff -2 - 4,
          90,
          "stroke-red-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )

        path06 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 6, angleDiff -2,
          90,
          "stroke-green-200 fill-none stroke-[25px]",
          "",
          "saturday"
        )

        text06 = this.generateTextPath(0, 0, "Сб", "#saturday", `-20px`)

        path061 = this.generatePath(
          101, 101,
          113, 113,
          30 + 2 + angleDiff * 6, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )

        path062 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 6, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )

        path063 = this.generatePath(
          101, 101,
          127, 127,
          30 + 2 + angleDiff * 6, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px]",
          "stroke-linecap: round"
        )

        path07 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 7, angleDiff -2,
          90,
          "stroke-slate-200 fill-none stroke-[10px]",
          "",
          "sunday"
        )
        text07 = this.generateTextPath(0, 0, "Вс", "#sunday", `-20px`)
        path071 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 7, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[1px] hidden",
          "stroke-linecap: round"
        )
         totalLength = path071.getTotalLength();



        textMainPercentage = this.generateText("50%", "70%", "72%", "3em")

        this.el.querySelector('svg').replaceChildren(
          path2, path, path3, path4, text3,
          path01, path011, path012, path013, text01,
          path02, path021, text02,
          path03, path031, path032, path033, path034, text03,
          path04, text04,
          path05, path051, path052, text05,
          path06, text06,
          path07, text07, path071,
          textMainPercentage
        )

  },

  generate2(){
        path = this.generatePath(
          101, 101,
          85, 85,
          75, 150,
          90,
          "stroke-green-500 fill-none stroke-[20px]",
          "stroke-linecap: round"
        )
      
        path2 = this.generatePath(
          101, 101,
          85, 85,
          75, 210,
          90,
          "stroke-slate-300 fill-none stroke-[11px]",
          "stroke-linecap: round"
        )

        path3 = this.generatePath(
          101, 101,
          85, 85,
          179, 45,
          90,
          "stroke-green-300 fill-none stroke-[11px]",
          "stroke-linecap: round",
          "diff"
        )
        text3 = this.generateTextPath(0, 0, "+ 23 %", "#diff", `25px`)
        text3.setAttributeNS(null, "font-size", "15px")
        text3.setAttributeNS(null, "class", "fill-green-500")

        path4 = this.generatePath(
          101, 101,
          85, 85,
          175, 2,
          90,
          "stroke-yellow-300 fill-none stroke-[30px]",
        )


        angleDiff = (200 / 6)
        path01 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff, angleDiff - 2,
          90,
          "stroke-green-200 fill-none stroke-[25px]",
          "",
          "monday"
        )
        text01 = this.generateTextPath(0, 0, "Пн", "#monday", `-20px`)

        path011 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff, angleDiff - 2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[1px] hidden",
          "stroke-linecap: round"
        )

         totalLength = path011.getTotalLength();
      circle011 = this.generateCircle(5, 0, 0, "fill-green-500")
      u = 0.15;
      p = path011.getPointAtLength(u * totalLength);
      circle011.setAttribute("transform",`translate(${p.x}, ${p.y})`)

      circle012 = this.generateCircle(5, 0, 0, "fill-green-500")
      u = 0.4;
      p = path011.getPointAtLength(u * totalLength);
      circle012.setAttribute("transform",`translate(${p.x}, ${p.y})`)

      circle013 = this.generateCircle(5, 0, 0, "fill-green-500")
      u = 0.65;
      p = path011.getPointAtLength(u * totalLength);
      circle013.setAttribute("transform",`translate(${p.x}, ${p.y})`)

      circle014 = this.generateCircle(5, 0, 0, "fill-red-500")
      u = 0.9;
      p = path011.getPointAtLength(u * totalLength);
      circle014.setAttribute("transform",`translate(${p.x}, ${p.y})`)


        path02 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 2, angleDiff - 2,
          90,
          "stroke-red-200 fill-none stroke-[25px]",
          "",
          "tuesday"
        )

        text02 = this.generateTextPath(0, 0, "Вт", "#tuesday", `-20px`)

        path021 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 2, angleDiff - 2 - 4,
          90,
          "stroke-red-400 fill-none stroke-[5px] hidden",
          "stroke-linecap: round"
        )

         totalLength = path021.getTotalLength();
    circle021 = this.generateCircle(5, 0, 0, "fill-red-500")
          u = 0.5;
          p = path021.getPointAtLength(u * totalLength);
          circle021.setAttribute("transform",`translate(${p.x}, ${p.y})`)


        path03 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 3, angleDiff -2,
          90,
          "stroke-green-200 fill-none stroke-[25px]",
          "",
          "wednesday"
        )

        text03 = this.generateTextPath(0, 0, "Ср", "#wednesday", `-20px`)

        path031 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 3, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px] hidden",
          "stroke-linecap: round"
        )
         totalLength = path031.getTotalLength();
    circle031 = this.generateCircle(5, 0, 0, "fill-green-500")
          u = 0.15;
          p = path031.getPointAtLength(u * totalLength);
          circle031.setAttribute("transform",`translate(${p.x}, ${p.y})`)

          circle032 = this.generateCircle(5, 0, 0, "fill-red-500")
          u = 0.5;
          p = path031.getPointAtLength(u * totalLength);
          circle032.setAttribute("transform",`translate(${p.x}, ${p.y})`)

          circle033 = this.generateCircle(5, 0, 0, "fill-green-500")
          u = 0.85;
          p = path031.getPointAtLength(u * totalLength);
          circle033.setAttribute("transform",`translate(${p.x}, ${p.y})`)




        path04 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 4, angleDiff -2,
          90,
          "stroke-green-200 fill-none stroke-[25px]",
          "",
          "thursday"
        )

        text04 = this.generateTextPath(0, 0, "Чт", "#thursday", `-20px`)

        path041 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 4, angleDiff - 2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px] hidden",
          "stroke-linecap: round"
        )
         totalLength = path041.getTotalLength();
       circle041 = this.generateCircle(4, 0, 0, "fill-green-500")
              u = 0.1;
              p = path041.getPointAtLength(u * totalLength);
              circle041.setAttribute("transform",`translate(${p.x}, ${p.y})`)

              circle042 = this.generateCircle(4, 0, 0, "fill-green-500")
              u = 0.3;
              p = path041.getPointAtLength(u * totalLength);
              circle042.setAttribute("transform",`translate(${p.x}, ${p.y})`)

              circle043 = this.generateCircle(4, 0, 0, "fill-green-500")
              u = 0.5;
              p = path041.getPointAtLength(u * totalLength);
              circle043.setAttribute("transform",`translate(${p.x}, ${p.y})`)

              circle044 = this.generateCircle(4, 0, 0, "fill-red-500")
              u = 0.7;
              p = path041.getPointAtLength(u * totalLength);
              circle044.setAttribute("transform",`translate(${p.x}, ${p.y})`)

              circle045 = this.generateCircle(4, 0, 0, "fill-green-500")
              u = 0.9;
              p = path041.getPointAtLength(u * totalLength);
              circle045.setAttribute("transform",`translate(${p.x}, ${p.y})`)



        path05 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 5, angleDiff -2,
          90,
          "stroke-red-200 fill-none stroke-[25px]",
          "",
          "friday"
        )
        text05 = this.generateTextPath(0, 0, "Пт", "#friday", `-20px`)

        path051 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 5, angleDiff -2 - 4,
          90,
          "stroke-red-500 fill-none stroke-[5px] hidden",
          "stroke-linecap: round"
        )
         totalLength = path051.getTotalLength();
       circle051 = this.generateCircle(5, 0, 0, "fill-red-500")
              u = 0.15;
              p = path051.getPointAtLength(u * totalLength);
              circle051.setAttribute("transform",`translate(${p.x}, ${p.y})`)

              circle052 = this.generateCircle(5, 0, 0, "fill-red-500")
              u = 0.5;
              p = path051.getPointAtLength(u * totalLength);
              circle052.setAttribute("transform",`translate(${p.x}, ${p.y})`)

              circle053 = this.generateCircle(5, 0, 0, "fill-red-500")
              u = 0.85;
              p = path051.getPointAtLength(u * totalLength);
              circle053.setAttribute("transform",`translate(${p.x}, ${p.y})`)



        path06 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 6, angleDiff -2,
          90,
          "stroke-green-200 fill-none stroke-[25px]",
          "",
          "saturday"
        )

        text06 = this.generateTextPath(0, 0, "Сб", "#saturday", `-20px`)

        path061 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 6, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[5px] hidden",
          "stroke-linecap: round"
        )
         totalLength = path061.getTotalLength();
       circle061 = this.generateCircle(5, 0, 0, "fill-green-500")
              u = 0.3;
              p = path061.getPointAtLength(u * totalLength);
              circle061.setAttribute("transform",`translate(${p.x}, ${p.y})`)

              circle062 = this.generateCircle(5, 0, 0, "fill-green-500")
              u = 0.7;
              p = path061.getPointAtLength(u * totalLength);
              circle062.setAttribute("transform",`translate(${p.x}, ${p.y})`)



        path07 = this.generatePath(
          101, 101,
          120, 120,
          30 + angleDiff * 7, angleDiff -2,
          90,
          "stroke-green-200 fill-none stroke-[25px]",
          "",
          "sunday"
        )
        text07 = this.generateTextPath(0, 0, "Вс", "#sunday", `-20px`)
        path071 = this.generatePath(
          101, 101,
          120, 120,
          30 + 2 + angleDiff * 7, angleDiff -2 - 4,
          90,
          "stroke-green-500 fill-none stroke-[1px] hidden",
          "stroke-linecap: round"
        )
         totalLength = path071.getTotalLength();


      circle071 = this.generateCircle(4, 0, 0, "fill-green-500")
      u = 0.1;
      p = path071.getPointAtLength(u * totalLength);
      circle071.setAttribute("transform",`translate(${p.x}, ${p.y})`)

      circle072 = this.generateCircle(4, 0, 0, "fill-green-500")
      u = 0.3;
      p = path071.getPointAtLength(u * totalLength);
      circle072.setAttribute("transform",`translate(${p.x}, ${p.y})`)

      circle073 = this.generateCircle(4, 0, 0, "fill-green-500")
      u = 0.5;
      p = path071.getPointAtLength(u * totalLength);
      circle073.setAttribute("transform",`translate(${p.x}, ${p.y})`)

      circle074 = this.generateCircle(4, 0, 0, "fill-red-500")
      u = 0.7;
      p = path071.getPointAtLength(u * totalLength);
      circle074.setAttribute("transform",`translate(${p.x}, ${p.y})`)

      circle075 = this.generateCircle(4, 0, 0, "fill-green-500")
      u = 0.9;
      p = path071.getPointAtLength(u * totalLength);
      circle075.setAttribute("transform",`translate(${p.x}, ${p.y})`)


        textMainPercentage = this.generateText("50%", "70%", "72%", "3em")

        this.el.querySelector('svg').replaceChildren(
          path2, path, path3, path4, text3,
          path01, path011, circle011, circle012, circle013, circle014, text01,
          path02, path021, circle021, text02,
          path03, path031,  circle031,  circle032,  circle033, text03,
          path04, path041,  circle041,  circle042,  circle043,  circle044,  circle045, text04,
          path05, path051, circle051, circle052, circle053, text05,
          path06, path061, circle061, circle062, text06,
          path07, text07, path071, circle071, circle072, circle073, circle074, circle075,
          textMainPercentage
        )
  },

  mounted(){
    this.handleEvent(`init_${this.el.id}`, (momentum) => {
      this.generate1();
      }
    )
  }
}


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", info => {
  topbar.hide()

  if(info.detail.kind === "initial"){
    window.Telegram.WebApp.ready()
  }
  if(window.Telegram){
    if(window.previousHandler) { 
      window.Telegram.WebApp.BackButton.offClick(window.previousHandler)
    }

    backButtons = document.querySelectorAll('.tg-back-button')
    console.log(backButtons)
    if(backButtons.length) {
      lastButton = backButtons[backButtons.length - 1]

      window.Telegram.WebApp.BackButton.show()
      window.previousHandler = () => {
        liveSocket.execJS(lastButton, lastButton.getAttribute("data-navigate"))
      }
      window.Telegram.WebApp.BackButton.onClick(previousHandler)
    }
    else {
      window.Telegram.WebApp.BackButton.hide()
    }
  }
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.onload = (event) => {
  window.Telegram.WebApp.expand()
  window.Telegram.WebApp.disableVerticalSwipes()

  window.Telegram.WebApp.SettingsButton.onClick(() => {
    settingsButton = document.querySelector('.tg-settings-button')
    res = window.liveSocket.execJS(settingsButton, settingsButton.getAttribute("data-navigate"))
  })
  window.Telegram.WebApp.SettingsButton.show()
};
