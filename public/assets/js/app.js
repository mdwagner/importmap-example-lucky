import Ujs from "@rails/ujs";
import Turbolinks from "turbolinks";
import Alpine from "alpinejs";

// Rails Unobtrusive JavaScript (UJS) is *required* for links in Lucky that use DELETE, POST and PUT.
// Though it says "Rails" it actually works with any framework.
Ujs.start();

// Turbolinks is optional. Learn more: https://github.com/turbolinks/turbolinks/
Turbolinks.start();

window.Alpine = Alpine;
Alpine.start();

import "./other.js";
