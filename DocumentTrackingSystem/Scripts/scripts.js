var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
})

var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl)
})

function TextEditor(field) {
    tinymce.init({
        selector: field,
        plugins: [
        'advlist', 'autolink', 'lists', 'link', 'image', 'charmap', 'preview',
        'anchor', 'searchreplace', 'visualblocks', 'code', 'fullscreen',
        'insertdatetime', 'media', 'table', 'help', 'wordcount'
        ],
        toolbar: 'blocks | ' +
        'bold italic backcolor forecolor | alignleft aligncenter ' +
        'alignright alignjustify | bullist numlist outdent indent | ' +
        'removeformat | help image',
        image_title: true,
        automatic_uploads: true,
        file_picker_types: 'image',
        file_picker_callback: (cb, value, meta) => {
            const input = document.createElement('input');
            input.setAttribute('type', 'file');
            input.setAttribute('accept', 'image/*');
            input.addEventListener('change', (e) => {
                const file = e.target.files[0];
                if (file.size > 2097152) {
                    alert("File is too big! Must be less than or equal to 2MB only");
                    return;
                };
                const reader = new FileReader();
                reader.addEventListener('load', () => {
                    const id = 'blobid' + (new Date()).getTime();
                    const blobCache = tinymce.activeEditor.editorUpload.blobCache;
                    const base64 = reader.result.split(',')[1];
                    const blobInfo = blobCache.create(id, file, base64);
                    blobCache.add(blobInfo);
                    cb(blobInfo.blobUri(), { title: file.name });
                });
                reader.readAsDataURL(file);
            });
            input.click();
        },
        content_style: 'body { font-family:Helvetica,Arial,sans-serif; font-size:16px }',
        branding: false,
        promotion: false
    });
}

function Ajax(url, data, dataType, success) {
    $.ajax({
        url: url,
        data : data,
        dataType: dataType,
        beforeSend: function() {
            $('#spinner').show();
        },
        success: success,
        complete: function () {
            $('#spinner').hide();
        }
    })
}

class tableCart {
    constructor() {

    }

    InitIndex(i) {
        $.each($(`#${$(i).attr('id')} tr`), function (i, item) {
            $.each($(item).find('input, select'), function (o, p) {
                $(p).attr('name', $(p).attr('name').replace(/\[([\d]+)\]/, `[${i - 1}]`));
            });
        });
    }

    Add(i) {
        var getTable = $(i).attr('data-tableTarget');
        $(`${getTable} tbody`).append(`<tr>${$($(`${getTable} tbody tr`)[0]).html()}</tr>`);
        InitIndex(getTable);
    }

    Remove(i) {
        var item = $(i).parents('tr')
        var table = $(i).find('table');
        if (item.index() != 0) {
            item.remove();
            InitIndex(`#${table.attr('id')}`);
        }
    }
}

$(document).ready(function () {
    var bootstrapButton = $.fn.button.noConflict()
    $.fn.bootstrapBtn = bootstrapButton;
});

var popupCenter = ({url , title, w, h}) => {
    // Fixes dual-screen position                             Most browsers      Firefox
    const dualScreenLeft = window.screenLeft !==  undefined ? window.screenLeft : window.screenX;
    const dualScreenTop = window.screenTop !==  undefined   ? window.screenTop  : window.screenY;

    const width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    const height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    const systemZoom = width / window.screen.availWidth;
    const left = (width - w) / 2 / systemZoom + dualScreenLeft
    const top = (height - h) / 2 / systemZoom + dualScreenTop
    const newWindow = window.open(url, title,
      `
      scrollbars=yes,
      width=${w / systemZoom},
      height=${h / systemZoom},
      top=${top},
      left=${left}
      `
    )

    if (window.focus) newWindow.focus();
}


$(document).ready(function () {
    $('.searchbox').select2();
    $.each($('#sidebar-nav .nav-item .nav-link, #sidebar-nav .nav-item a'), function (i, item) {
        if ($(item).attr('href') == location.pathname + location.search) {
            $(item).parent('li').parent('ul').addClass('show');
            $(item).parent('li').parent('ul').siblings('a').removeClass('collapsed');
            $(item).addClass('active');
            $(item).removeClass('collapsed');
        }
    });
});