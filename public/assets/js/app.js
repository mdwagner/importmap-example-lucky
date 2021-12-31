/* eslint no-console:0 */

// Rails Unobtrusive JavaScript (UJS) is *required* for links in Lucky that use DELETE, POST and PUT.
// Though it says "Rails" it actually works with any framework.
import Ujs from "@rails/ujs";
Ujs.start();

// Turbolinks is optional. Learn more: https://github.com/turbolinks/turbolinks/
import Turbolinks from "turbolinks";
Turbolinks.start();

import Alpine from "alpinejs";
window.Alpine = Alpine;
Alpine.start();

import React from "react";
window.React = React;

import "./other.js";
