import { gsap } from "gsap";
import { MotionPathPlugin } from "gsap/MotionPathPlugin.js";

window.onload = function() {
  gsap.registerPlugin(MotionPathPlugin);
}
