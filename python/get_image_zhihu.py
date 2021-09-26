import requests
from lxml import etree

# 获取知乎上文章里的图片

headers = {
    "user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36",
    "sec-ch-ua":'"Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"',
    "cookie":''
}

url = "https://zhuanlan.zhihu.com/p/70459013"

respones = requests.get(url=url,headers=headers)
respones.encoding = 'utf-8'

def wget_img(url):
    file_name = str(url).split('/')[-1]  # 从url获取文件名
    r = requests.get(url, stream=True, headers=headers)  # 请求链接
    with open('test\%s' % file_name, 'wb+') as f:  # 创建文件
        f.write(r.content)  # 写入图片
    print("%s 下载完成..." % url)  # 打印信息

def spider_img(respones):
    html = respones.text
    html = etree.HTML(html)
    img_list = html.xpath('//*[@id="root"]//article//img/@src')
    for i in img_list:
        try:
            img_path = "https://" + str(i).split("https://")[1].split(".jpg")[0] + ".jpg"
            wget_img(img_path)
        except IndexError:
            pass


def spider_text(respones):
    html = respones.text
    html = etree.HTML(html)
    txt = html.xpath('//*[@id="root"]/div/main/div/article//text()')
    for i in txt:
        with open('tmp.txt','a+',encoding='utf-8') as f:
            i = str(i)
            f.write(i)

if __name__ == '__main__':
    spider_text(respones)
    spider_img(respones)