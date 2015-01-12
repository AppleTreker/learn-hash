steps = []
step_num = 0

function Step(html_content, preload, callback_function) {
    this.html = html_content;
    this.test = callback_function;
    this.code = preload;
}

function btn_stepper(code, result) {
    var success = steps[step_num].test(code, result);
    if (success) {
        step_num++;
        set_html(steps[step_num].html);
        set_editor(steps[step_num].code);
    }
}