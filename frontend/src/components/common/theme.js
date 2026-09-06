/* ============================================================
   明暗模式切换（参考 dufs-zh）
   优先级：localStorage("fan-theme") > 系统偏好
   <html data-theme="dark|light">
   ============================================================ */
(function () {
    "use strict";

    var STORAGE_KEY = "fan-theme";

    function getPreferredTheme() {
        return localStorage.getItem(STORAGE_KEY) || "system";
    }

    function resolveTheme(choice) {
        if (choice === "dark") return "dark";
        if (choice === "light") return "light";
        return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    }

    function applyTheme(theme) {
        var el = document.documentElement;
        el.removeAttribute("data-theme");
        el.setAttribute("data-theme", theme);
    }

    function toggleTheme() {
        var current = resolveTheme(getPreferredTheme());
        var next = current === "dark" ? "light" : "dark";

        if (document.startViewTransition) {
            var transition = document.startViewTransition(function () {
                applyTheme(next);
            });
            if (transition && transition.ready) {
                transition.ready.then(function () {
                    var centerX = 24;
                    var centerY = window.innerHeight - 24;
                    var radius = Math.hypot(
                        Math.max(centerX, window.innerWidth - centerX),
                        Math.max(centerY, window.innerHeight - centerY)
                    );
                    document.documentElement.animate(
                        {
                            clipPath: [
                                "circle(0% at " + centerX + "px " + centerY + "px)",
                                "circle(" + radius + "px at " + centerX + "px " + centerY + "px)",
                            ],
                        },
                        {
                            duration: 520,
                            easing: "ease-in-out",
                            pseudoElement: "::view-transition-new(root)",
                        }
                    );
                });
            }
        } else {
            var html = document.documentElement;
            html.classList.add("theme-transition");
            applyTheme(next);
            window.setTimeout(function () {
                html.classList.remove("theme-transition");
            }, 380);
        }
    }

    function buildButton() {
        var btn = document.createElement("button");
        btn.className = "theme-toggle";
        btn.type = "button";
        btn.title = "切换明暗模式";
        btn.setAttribute("aria-label", "切换明暗模式");

        btn.innerHTML =
            '<svg class="theme-icon theme-icon-sun" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
            '<circle cx="12" cy="12" r="5"></circle>' +
            '<line x1="12" y1="1" x2="12" y2="3"></line>' +
            '<line x1="12" y1="21" x2="12" y2="23"></line>' +
            '<line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>' +
            '<line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>' +
            '<line x1="1" y1="12" x2="3" y2="12"></line>' +
            '<line x1="21" y1="12" x2="23" y2="12"></line>' +
            '<line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>' +
            '<line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>' +
            "</svg>" +
            '<svg class="theme-icon theme-icon-moon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
            '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>' +
            "</svg>";

        btn.addEventListener("click", toggleTheme);
        document.body.appendChild(btn);
    }

    document.addEventListener("DOMContentLoaded", function () {
        applyTheme(resolveTheme(getPreferredTheme()));
        buildButton();
    });

    window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", function () {
        if (getPreferredTheme() === "system") {
            applyTheme(resolveTheme("system"));
        }
    });
})();