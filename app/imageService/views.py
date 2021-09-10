import io
import os

import aiohttp_jinja2
from aiohttp import web
from PIL import Image
import time


def keyCookie(request):
    key_cookie = request.cookies.get('key')
    if key_cookie is None:
        key_cookie = hash(time.time())
    return key_cookie


def hex_to_rgb(value):
    value = value.lstrip('#')
    lv = len(value)
    return tuple(int(value[i:i + lv // 3], 16) for i in range(0, lv, lv // 3))


def pixelCount(color, image_pil):
    count = 0
    rgb_col = hex_to_rgb(color)
    for pixel in image_pil.getdata():
        if pixel == rgb_col:  # if your image is RGB (if RGBA, (0, 0, 0, 255) or so
            count += 1
    return count


# создаем функцию, которая будет отдавать html-файл
async def index(request):
    key_cookie = keyCookie(request)
    white = pixelCount("#FFFFFF", Image.open(f"static/image/{key_cookie}.jpg", "r"))
    black = pixelCount("#000000", Image.open(f"static/image/{key_cookie}.jpg", "r"))
    try:
        color_hex = request.query['color']
    except KeyError as e:
        color_hex = "#000000"
    color = pixelCount(color_hex, Image.open(f"static/image/{key_cookie}.jpg", "r"))
    context = {
        'key_cookie': key_cookie,
        'white': white,
        'black': black,
        'color_hex': color_hex,
        'color': color
    }
    response = aiohttp_jinja2.render_template("index.html", request=request, context=context)
    response.set_cookie(name="key", value=key_cookie)
    return response


async def image(request):
    key_cookie = keyCookie(request)
    post = await request.post()
    image = post.get("image")
    img_content = image.file.read()
    with open(f"static/image/{key_cookie}.jpg", "wb") as f:
        f.write(img_content)
    response = web.HTTPFound('/')
    response.set_cookie(name="key", value=key_cookie)
    return response
