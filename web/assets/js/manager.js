(function () {
    "use strict";
    var toggle = document.querySelector("[data-sidebar-toggle]");
    if (toggle) toggle.addEventListener("click", function () { document.body.classList.toggle("sidebar-open"); });
    var forms = document.querySelectorAll("form[data-confirm]");
    for (var i = 0; i < forms.length; i++) {
        forms[i].addEventListener("submit", function (event) {
            if (!window.confirm(this.getAttribute("data-confirm"))) event.preventDefault();
        });
    }
    var automaticSelects = document.querySelectorAll("[data-submit-on-change]");
    for (var selectIndex = 0; selectIndex < automaticSelects.length; selectIndex++) {
        automaticSelects[selectIndex].addEventListener("change", function () {
            if (this.form) this.form.submit();
        });
    }
})();
