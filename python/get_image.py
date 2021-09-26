# 自动爬取图片

import requests
import re

def get_image(url):
    # 1.获取页面信息 2.用正则查找页面里的图片url 3.返回正则图片列表
    get_url  = requests.get(url)
    if get_url.status_code == 200:
        get_url = get_url.text
        get_img = r'this.src=.*?"'
        img = re.findall(get_img, get_url)
        return img
    else:
        print("URL is error")
        exit()
def save_img(num, form):
    # 3.    保存图片到本地，名字.格式 通过传参拼接
    file = "E:\PycharmProjects\OnePiece\img\{0}.{1}".format(num, form)
    # with open以二进制格式打开文件，完成后，自动关闭文件
    with open(file, 'wb') as t:
        # 写入转换的二进制数据
        t.write(i)
        # 输出保存的文件路径
        print(file)



if __name__ == '__main__':
    # url = "http://www.doutula.com/article/detail/5164060"
    # url = "http://www.doutula.com/article/detail/5043014"
    url = "http://www.doutula.com/article/detail/9593553"
    img = get_image(url)
    for i in img:
        # 加载正则图片列表，获取图片URL地址
        i = i.split("'")[1]
        # 获取图片名字
        num = i.split("/")[-1].split(".")[0]
        # 获取图片格式
        xxx = i.split(".")[-1]
        # 将图片转换成二进制
        i = requests.get(i).content
        # 调用保存图片函数
        save_img(num, xxx)

