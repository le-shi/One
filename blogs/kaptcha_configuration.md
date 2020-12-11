| Constant | Description | Default | 
|:-------------|:----------------|:------------|
| kaptcha.border | Border around kaptcha. Legal values are yes or no. | yes | 
| kaptcha.border.color | Color of the border. Legal values are r,g,b (and optional alpha) or white,black,blue. | black | 
| kaptcha.border.thickness | Thickness of the border around kaptcha. Legal values are > 0. | 1 | 
| kaptcha.image.width | Width in pixels of the kaptcha image. | 200 | 
| kaptcha.image.height | Height in pixels of the kaptcha image. | 50 | 
| kaptcha.producer.impl | The image producer. | com.google.code.kaptcha.impl.DefaultKaptcha | 
| kaptcha.textproducer.impl | The text producer. | com.google.code.kaptcha.text.impl.DefaultTextCreator | 
| kaptcha.textproducer.char.string | The characters that will create the kaptcha. | abcde2345678gfynmnpwx | 
| kaptcha.textproducer.char.length | The number of characters to display. | 5 | 
| kaptcha.textproducer.font.names | A list of comma separated font names. | Arial, Courier | 
| kaptcha.textproducer.font.size | The size of the font to use. | 40px. | 
| kaptcha.textproducer.font.color | The color to use for the font. Legal values are r,g,b. | black | 
| kaptcha.textproducer.char.space | The space between the characters | 2 | 
| kaptcha.noise.impl | The noise producer. | com.google.code.kaptcha.impl.DefaultNoise | 
| kaptcha.noise.color | The noise color. Legal values are r,g,b. | black | 
| kaptcha.obscurificator.impl | The obscurificator implementation. | com.google.code.kaptcha.impl.WaterRipple | 
| kaptcha.background.impl | The background implementation. | com.google.code.kaptcha.impl.DefaultBackground | 
| kaptcha.background.clear.from | Starting background color. Legal values are r,g,b. | light grey | 
| kaptcha.background.clear.to | Ending background color. Legal values are r,g,b. | white | 
| kaptcha.word.impl | The word renderer implementation. | com.google.code.kaptcha.text.impl.DefaultWordRenderer | 
| kaptcha.session.key | The value for the kaptcha is generated and is put into the HttpSession. This is the key value for that item in the session. | KAPTCHA_SESSION_KEY | 
| kaptcha.session.date | The date the kaptcha is generated is put into the HttpSession. This is the key value for that item in the session. | KAPTCHA_SESSION_DATE |

---

| Constant | 描述 | 默认值|
|:-------------|:----------------|:------------|
| kaptcha.border | 图片边框，合法值：yes , no | yes|
| kaptcha.border.color | 边框颜色，合法值： r,g,b (and optional alpha) 或者 white,black,blue. | black|
| kaptcha.border.thickness | 边框厚度，合法值：>0 | 1|
| kaptcha.image.width | 图片宽 | 200|
| kaptcha.image.height | 图片高 | 50|
| kaptcha.producer.impl | 图片实现类 | com.google.code.kaptcha.impl.DefaultKaptcha|
| kaptcha.textproducer.impl | 文本实现类 | com.google.code.kaptcha.text.impl.DefaultTextCreator|
| kaptcha.textproducer.char.string | 文本集合，验证码值从此集合中获取 | abcde2345678gfynmnpwx|
| kaptcha.textproducer.char.length | 验证码长度 | 5|
| kaptcha.textproducer.font.names | 字体 | Arial, Courier|
| kaptcha.textproducer.font.size | 字体大小 | 40px|
| kaptcha.textproducer.font.color | 字体颜色，合法值： r,g,b  或者 white,black,blue. | black|
| kaptcha.textproducer.char.space | 文字间隔 | 2|
| kaptcha.noise.impl | 干扰实现类 | com.google.code.kaptcha.impl.DefaultNoise|
| kaptcha.noise.color | 干扰颜色，合法值： r,g,b 或者 white,black,blue. | black|
| kaptcha.obscurificator.impl | 图片样式：<br>水纹com.google.code.kaptcha.impl.WaterRipple<br>鱼眼com.google.code.kaptcha.impl.FishEyeGimpy<br> 阴影com.google.code.kaptcha.impl.ShadowGimpy | com.google.code.kaptcha.impl.WaterRipple|
| kaptcha.background.impl | 背景实现类 | com.google.code.kaptcha.impl.DefaultBackground|
| kaptcha.background.clear.from | 背景颜色渐变，开始颜色 | light grey|
| kaptcha.background.clear.to | 背景颜色渐变，结束颜色 | white|
| kaptcha.word.impl | 文字渲染器 | com.google.code.kaptcha.text.impl.DefaultWordRenderer|
| kaptcha.session.key | session key | KAPTCHA_SESSION_KEY|
| kaptcha.session.date | session date | KAPTCHA_SESSION_DATE|