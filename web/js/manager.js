(function () {
    "use strict";

    document.addEventListener("DOMContentLoaded", function () {
        var toggle = document.querySelector("[data-sidebar-toggle]");
        if (toggle) {
            toggle.addEventListener("click", function () {
                document.body.classList.toggle("sidebar-open");
            });
        }

        var forms = document.querySelectorAll("form[data-confirm]");
        for (var i = 0; i < forms.length; i++) {
            forms[i].addEventListener("submit", function (event) {
                if (!window.confirm(this.getAttribute("data-confirm"))) {
                    event.preventDefault();
                }
            });
        }

        var automaticSelects = document.querySelectorAll("[data-submit-on-change]");
        for (var selectIndex = 0; selectIndex < automaticSelects.length; selectIndex++) {
            automaticSelects[selectIndex].addEventListener("change", function () {
                if (this.form) {
                    this.form.submit();
                }
            });
        }

        setupTablePagination();
    });

    function setupTablePagination() {
        var pageSize = 10;
        var tables = document.querySelectorAll(".manager-table");

        for (var tableIndex = 0; tableIndex < tables.length; tableIndex++) {
            setupOneTable(tables[tableIndex], pageSize);
        }
    }

    function setupOneTable(table, pageSize) {
        var rows = Array.prototype.slice.call(table.querySelectorAll("tbody tr")).filter(function (row) {
            return !row.querySelector(".empty-row");
        });

        if (rows.length <= pageSize) {
            return;
        }

        var panel = table.closest(".data-panel");
        var pagination = panel ? panel.querySelector(".pagination") : null;
        var footerLabel = panel ? panel.querySelector(".table-footer > span") : null;

        if (!pagination) {
            return;
        }

        var currentPage = 0;
        var pageCount = Math.ceil(rows.length / pageSize);

        function renderPage(page) {
            currentPage = Math.max(0, Math.min(page, pageCount - 1));

            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
                var visible = rowIndex >= currentPage * pageSize && rowIndex < (currentPage + 1) * pageSize;
                rows[rowIndex].style.display = visible ? "" : "none";
            }

            if (footerLabel) {
                var start = currentPage * pageSize + 1;
                var end = Math.min((currentPage + 1) * pageSize, rows.length);
                footerLabel.innerHTML = "Hiển thị <strong>" + start + "-" + end + "</strong> / " + rows.length;
            }

            var pageButtons = pagination.querySelectorAll("[data-page]");
            for (var buttonIndex = 0; buttonIndex < pageButtons.length; buttonIndex++) {
                pageButtons[buttonIndex].classList.toggle("is-active", Number(pageButtons[buttonIndex].getAttribute("data-page")) === currentPage);
            }

            var previous = pagination.querySelector("[data-page-prev]");
            var next = pagination.querySelector("[data-page-next]");
            if (previous) {
                previous.disabled = currentPage === 0;
            }
            if (next) {
                next.disabled = currentPage >= pageCount - 1;
            }
        }

        pagination.innerHTML = "";
        pagination.appendChild(createNavButton("&lsaquo;", "data-page-prev"));

        for (var pageIndex = 0; pageIndex < pageCount; pageIndex++) {
            var pageButton = document.createElement("button");
            pageButton.type = "button";
            pageButton.textContent = String(pageIndex + 1);
            pageButton.setAttribute("data-page", String(pageIndex));
            pagination.appendChild(pageButton);
        }

        pagination.appendChild(createNavButton("&rsaquo;", "data-page-next"));

        pagination.addEventListener("click", function (event) {
            var target = event.target.closest("button");
            if (!target) {
                return;
            }

            if (target.hasAttribute("data-page")) {
                renderPage(Number(target.getAttribute("data-page")) || 0);
            } else if (target.hasAttribute("data-page-prev")) {
                renderPage(currentPage - 1);
            } else if (target.hasAttribute("data-page-next")) {
                renderPage(currentPage + 1);
            }
        });

        renderPage(0);
    }

    function createNavButton(label, attributeName) {
        var button = document.createElement("button");
        button.type = "button";
        button.innerHTML = label;
        button.setAttribute(attributeName, "true");
        return button;
    }
})();
