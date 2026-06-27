/*
 Navicat Premium Dump SQL

 Source Server         : demo
 Source Server Type    : MySQL
 Source Server Version : 80040 (8.0.40)
 Source Host           : localhost:3306
 Source Schema         : english_learning_mate

 Target Server Type    : MySQL
 Target Server Version : 80040 (8.0.40)
 File Encoding         : 65001

 Date: 27/04/2026 23:38:26
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ai_article_log
-- ----------------------------
DROP TABLE IF EXISTS `ai_article_log`;
CREATE TABLE `ai_article_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
  `word_bank_id` bigint NOT NULL COMMENT '词库ID（逻辑外键，关联word_bank.id）',
  `theme` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文章主题',
  `difficulty` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '难度：EASY/MEDIUM/HARD/PROFESSIONAL',
  `length` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '长度：SHORT/MEDIUM/LONG',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文章内容',
  `highlight_words` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '高亮单词（JSON格式）',
  `translation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '中文翻译内容',
  `duration` int NOT NULL COMMENT '生成耗时（毫秒）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-成功，0-失败',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_word_bank_id`(`word_bank_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_user_status_created`(`user_id` ASC, `status` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI文章生成日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_article_log
-- ----------------------------
INSERT INTO `ai_article_log` VALUES (1, 2, 4, '科技', 'MEDIUM', 'SHORT', 'Algorithms and databases are basic concepts in computer science.', '[\"algorithm\",\"database\"]', NULL, 1320, 1, '2026-04-14 13:05:41');
INSERT INTO `ai_article_log` VALUES (2, 3, 6, '职场', 'PROFESSIONAL', 'MEDIUM', 'Negotiating a contract requires patience, clear goals and business awareness.', '[\"contract\",\"negotiate\"]', NULL, 1680, 1, '2026-04-14 13:05:41');
INSERT INTO `ai_article_log` VALUES (8, 5, 8, 'General', 'EASY', 'SHORT', 'I just returned from a wonderful vacation. The weather was cold, so I wore a warm coat every day. We walked straight to the beach each morning. I do not hate the cold, so I was unfazed by the wind.\n\nThe sea had a continuous sound that was very peaceful. It helped me forget any sorrowful feelings. I saw a figure walking far away along the shore. It was a very calm scene.\n\nI like to keep my life simple. I do not need a complex configstaff for my daily plans. Sometimes, the best moments are the simple ones. A quiet walk or a good book can be perfect.\n\nThis trip was a good test for my new routine. It showed me that happiness is often close by. I will remember this lesson for a long time.', '[{\"wordId\":109,\"english\":\"figure\",\"chinese\":\"数字；人物；认为\"},{\"wordId\":110,\"english\":\"vacation\",\"chinese\":\"假期，休假\"},{\"wordId\":91,\"english\":\"coat\",\"chinese\":\"外套；涂层\"},{\"wordId\":107,\"english\":\"straight\",\"chinese\":\"直的；直接地\"},{\"wordId\":100,\"english\":\"just\",\"chinese\":\"刚刚；仅仅；公正地\"},{\"wordId\":99,\"english\":\"hate\",\"chinese\":\"憎恨，讨厌\"},{\"wordId\":113,\"english\":\"unfazed\",\"chinese\":\"不慌不忙的，镇定的\"},{\"wordId\":89,\"english\":\"continuous\",\"chinese\":\"连续的，持续的\"},{\"wordId\":98,\"english\":\"sorrowful\",\"chinese\":\"悲伤的，悲痛的\"},{\"wordId\":82,\"english\":\"configstaff\",\"chinese\":\"配置人员\"}]', NULL, 6253, 1, '2026-04-15 09:58:39');
INSERT INTO `ai_article_log` VALUES (9, 30, 3, '校园', 'EASY', 'SHORT', 'A school campus is a busy place. Students walk to classes every day. They meet friends and talk. Teachers work hard to help them learn. The goal is to retain knowledge for a long time. This helps in future jobs and life.\n\nStudents often compile notes from their lessons. They write down important points. This makes studying for tests easier. Good notes are a key to success. Everyone has their own way to learn.\n\nSome old school rules do not work well now. Schools sometimes abolish these rules. They make new rules that are better for today. This keeps the school a happy and fair place for all.\n\nThe campus is full of energy. It is a place for growth and new ideas. Every student has a chance to do well here. It is the heart of learning for young people.', '[{\"wordId\":9,\"english\":\"retain\",\"chinese\":\"保持；保留\"},{\"wordId\":8,\"english\":\"compile\",\"chinese\":\"编写；汇编\"},{\"wordId\":7,\"english\":\"abolish\",\"chinese\":\"废除；取消\"}]', NULL, 7004, 0, '2026-04-15 10:44:20');
INSERT INTO `ai_article_log` VALUES (10, 30, 1, '科技', 'EASY', 'SHORT', 'Technology is changing our lives. It helps us in many ways. For example, we can talk to friends far away. We can find information quickly. Technology gives us the ability to learn new things easily.\n\nWe use a smart approach to solve problems. People create new apps and tools. These tools make work faster and simpler. We can achieve great things with the help of computers and phones.\n\nTechnology is in our homes, schools, and offices. It makes daily tasks easier. We can shop online or watch lessons on the internet. Life is more convenient now.\n\nIn the future, technology will keep improving. It will help us live better. We should use it wisely to help everyone.', '[{\"wordId\":2,\"english\":\"achieve\",\"chinese\":\"实现；达到\"},{\"wordId\":1,\"english\":\"ability\",\"chinese\":\"能力；才能\"},{\"wordId\":3,\"english\":\"approach\",\"chinese\":\"方法；接近\"}]', NULL, 6782, 1, '2026-04-15 17:45:33');
INSERT INTO `ai_article_log` VALUES (11, 5, 8, '科技', 'EASY', 'SHORT', 'Technology is part of our daily lives. We use it from the moment we wake up. A simple stroll in the park almost always involves a smartphone. These devices enable us to connect with friends far away.\n\nSome new inventions are quite amazing. For example, a special coating on phone screens can make them very strong. This helps keep the screen pure and clear. Scientists figure out how to make these materials better every year.\n\nThe level of technology keeps rising. It is rather exciting to see what comes next. Sometimes, new gadgets can surprise us. They make complex tasks simple and fun for everyone.', '[{\"wordId\":114,\"english\":\"moment\",\"chinese\":\"时刻，瞬间\"},{\"wordId\":111,\"english\":\"stroll\",\"chinese\":\"散步，闲逛\"},{\"wordId\":103,\"english\":\"almost\",\"chinese\":\"几乎，差不多\"},{\"wordId\":90,\"english\":\"coating\",\"chinese\":\"涂层，覆盖层\"},{\"wordId\":85,\"english\":\"enable\",\"chinese\":\"启用，使能够\"},{\"wordId\":94,\"english\":\"pure\",\"chinese\":\"纯净的，纯粹的\"},{\"wordId\":109,\"english\":\"figure\",\"chinese\":\"数字；人物；认为\"},{\"wordId\":106,\"english\":\"level\",\"chinese\":\"水平；等级；楼层\"},{\"wordId\":101,\"english\":\"rather\",\"chinese\":\"宁愿；相当\"}]', NULL, 6554, 1, '2026-04-15 22:38:51');
INSERT INTO `ai_article_log` VALUES (12, 5, 8, '校园生活', 'EASY', 'MEDIUM', 'My school life is full of small changes. Every new semester is a transition from one routine to another. I see this in the daily display of student work on the walls. The configstaff in our computer lab helps us when we have problems. They are always patient and kind.\n\nI must admit, I sometimes hate waking up early for morning classes. I would rather sleep a little longer. But I enjoy meeting my friends in the cafeteria. We talk and laugh during these peaceful moments. It makes the morning better.\n\nWe all look forward to vacation. It is a time to rest and have fun. During the last break, I updated my social media profile with many holiday pictures. I posted an instant photo of a beautiful sunset. My friends liked it very much.\n\nSchool is not always easy. We have tests and homework. But there are many good parts, too. I learn new things and grow every day. I will remember these school days for a long time.', '[{\"wordId\":82,\"english\":\"configstaff\",\"chinese\":\"配置人员\"},{\"wordId\":87,\"english\":\"transition\",\"chinese\":\"过渡，转变\"},{\"wordId\":86,\"english\":\"display\",\"chinese\":\"显示，展示\"},{\"wordId\":99,\"english\":\"hate\",\"chinese\":\"憎恨，讨厌\"},{\"wordId\":101,\"english\":\"rather\",\"chinese\":\"宁愿；相当\"},{\"wordId\":110,\"english\":\"vacation\",\"chinese\":\"假期，休假\"},{\"wordId\":88,\"english\":\"instant\",\"chinese\":\"立即的，瞬间\"},{\"wordId\":96,\"english\":\"profile\",\"chinese\":\"轮廓；简介；用户资料\"}]', NULL, 8800, 1, '2026-04-15 22:41:55');
INSERT INTO `ai_article_log` VALUES (13, 5, 8, '游戏', 'EASY', 'SHORT', 'Games are fun for many people. They just help you relax after a long day. Some people hate difficult games, but others enjoy a challenge. An instant win can feel very good.\n\nYou might wear a comfortable coat and play for hours. Sometimes you go straight to your favorite game after work. You probably have another game you want to try next. It feels like a short vacation from real life.\n\nThe continuous action in some games is exciting. This can enable you to forget your worries. Playing games is a nice test of your skills. It is a great way to have fun alone or with friends.', '[{\"wordId\":100,\"english\":\"just\",\"chinese\":\"刚刚；仅仅；公正地\"},{\"wordId\":99,\"english\":\"hate\",\"chinese\":\"憎恨，讨厌\"},{\"wordId\":88,\"english\":\"instant\",\"chinese\":\"立即的，瞬间\"},{\"wordId\":91,\"english\":\"coat\",\"chinese\":\"外套；涂层\"},{\"wordId\":107,\"english\":\"straight\",\"chinese\":\"直的；直接地\"},{\"wordId\":108,\"english\":\"probably\",\"chinese\":\"很可能，大概\"},{\"wordId\":104,\"english\":\"another\",\"chinese\":\"另一个\"},{\"wordId\":110,\"english\":\"vacation\",\"chinese\":\"假期，休假\"},{\"wordId\":89,\"english\":\"continuous\",\"chinese\":\"连续的，持续的\"},{\"wordId\":85,\"english\":\"enable\",\"chinese\":\"启用，使能够\"}]', NULL, 6281, 1, '2026-04-15 23:18:34');
INSERT INTO `ai_article_log` VALUES (14, 35, 12, '校园', 'EASY', 'SHORT', 'My school is a fun place. Every day, I say hello to my friends. We learn many things. We study math and science. We also read books. I like to learn about the world.\n\nIn class, we use computers. The computer helps us learn. We watch videos. We also write stories. It is very interesting. I enjoy using the computer.\n\nI am learning English. English is important. Many people in the world speak English. I practice every day. I read English books. I also speak with my teacher.\n\nSchool helps me grow. I learn new things every day. I make good friends here. I am happy at school. It is a great place to be.', '[{\"wordId\":116,\"english\":\"world\",\"chinese\":\"世界\"},{\"wordId\":119,\"english\":\"study\",\"chinese\":\"Study makes me happy.\"},{\"wordId\":118,\"english\":\"english\",\"chinese\":\"I am learning English.\"},{\"wordId\":117,\"english\":\"computer\",\"chinese\":\"I use computer every day.\"},{\"wordId\":115,\"english\":\"hello\",\"chinese\":\"你好\"}]', '我的学校是个有趣的地方。每天我都会和朋友们打招呼。我们学习许多知识，包括数学和科学，还会阅读书籍。我喜欢了解这个世界。\n\n课堂上我们会使用电脑。电脑帮助我们学习，我们可以观看视频，也能编写故事。这非常有意思，我很喜欢使用电脑。\n\n我正在学习英语。英语很重要，世界上有许多人说英语。我每天都会练习，阅读英文书籍，也会和老师用英语交流。\n\n学校帮助我成长。我每天都在学习新知识，在这里结交好朋友。我在学校很快乐，这是个很棒的地方。', 6188, 0, '2026-04-18 01:35:43');
INSERT INTO `ai_article_log` VALUES (15, 35, 2, '科技', 'EASY', 'SHORT', 'Technology changes our lives every day. It helps us work faster and learn new things. Many people enjoy using new gadgets and apps. Some people are more conservative about technology. They prefer old ways of doing things. Both views are common in our society.\n\nWe derive great benefits from modern tools. Smartphones let us talk to friends far away. Computers help us solve difficult problems. Technology can also accelerate progress in many fields. For example, doctors use it to find new medicines faster.\n\nHowever, we must use technology wisely. It is important to take breaks from screens. We should also protect our personal information online. Technology is a powerful tool for good. Let\'s use it to build a better future for everyone.', '[{\"wordId\":4,\"english\":\"accelerate\",\"chinese\":\"加速；促进\"},{\"wordId\":5,\"english\":\"conservative\",\"chinese\":\"保守的；守旧的\"},{\"wordId\":6,\"english\":\"derive\",\"chinese\":\"获得；起源于\"}]', '科技每天都在改变我们的生活。它帮助我们更高效地工作，学习新知识。许多人喜欢使用新奇的电子设备和应用程序。也有些人对科技持更保守的态度，他们更偏爱传统的生活方式。这两种观点在我们的社会中都很常见。\n\n现代工具为我们带来了巨大便利。智能手机让我们能与远方的朋友畅谈，计算机帮助我们解决复杂难题。科技还能加速许多领域的进步，例如医生借助科技能更快研发新药物。\n\n然而，我们必须明智地运用科技。适时远离电子屏幕十分重要，同时也应当注意保护网络个人信息。科技是推动社会进步的强大工具，让我们用它为所有人创造更美好的未来。', 5427, 1, '2026-04-18 09:36:57');
INSERT INTO `ai_article_log` VALUES (16, 35, 13, 'General', 'EASY', 'SHORT', 'AI 结果未包含目标词汇', '[]', NULL, 7115, 0, '2026-04-19 00:16:09');
INSERT INTO `ai_article_log` VALUES (17, 35, 13, '校园', 'EASY', 'SHORT', 'AI 结果未包含目标词汇', '[]', NULL, 5776, 0, '2026-04-19 00:16:50');
INSERT INTO `ai_article_log` VALUES (18, 35, 13, '校园', 'EASY', 'SHORT', '学校の図書館は静かです。彼は毎日ここで勉強します。今日は涼しい日です。窓の外で雨が降っています。\n\n彼は辞書を使って単語を書きます。どうしてそんなにたくさん勉強するのでしょうか。来月、大切な試験があるからです。\n\n時々、彼はパンを食べながら勉強します。図書館では食事ができませんが、これは小さなパンです。先生も見ません。\n\n先月、彼は病院に行きました。でも、今は元気です。雨の日も、彼は図書館で勉強を続けます。', '[{\"wordId\":211,\"english\":\"図書館\",\"chinese\":\"图书馆\"},{\"wordId\":158,\"english\":\"彼\",\"chinese\":\"他\"},{\"wordId\":195,\"english\":\"辞書\",\"chinese\":\"字典\"},{\"wordId\":142,\"english\":\"月\",\"chinese\":\"月亮/月份\"},{\"wordId\":212,\"english\":\"病院\",\"chinese\":\"医院\"},{\"wordId\":282,\"english\":\"どうして\",\"chinese\":\"为什么\"},{\"wordId\":263,\"english\":\"涼しい\",\"chinese\":\"凉爽的\"},{\"wordId\":178,\"english\":\"パン\",\"chinese\":\"面包\"},{\"wordId\":302,\"english\":\"雨\",\"chinese\":\"雨\"}]', '学校图书馆很安静。他每天在这里学习。今天是个凉爽的日子。窗外正下着雨。\n\n他使用词典来书写单词。为什么他要如此刻苦学习呢？因为下个月有一场重要的考试。\n\n有时，他会边吃面包边学习。图书馆里不允许用餐，但这只是个小面包。老师也不会注意到。\n\n上个月，他曾去医院看病。不过，现在他已经康复了。即便是雨天，他依然坚持在图书馆学习。', 5524, 1, '2026-04-19 00:19:01');
INSERT INTO `ai_article_log` VALUES (19, 35, 13, '旅行', 'EASY', 'SHORT', '旅行は楽しいです。先週、姉と公園へ行きました。公園で彼らが走っていました。あの子供たちはとても元気でした。\n\n火曜日に、また公園へ行きます。今度は牛乳といちごを持っていきます。公園でピクニックをします。とても楽しみです。\n\n毎週、新しい場所へ行きたいです。旅行はいい気分転換になります。ただいま、次の旅行の計画をしています。もっと日本の美しい場所を見たいです。\n\n簡単な旅行でも、たくさんの発見があります。友達や家族と一緒に行くのがおすすめです。皆さんも、ぜひ旅行を楽しんでください。', '[{\"wordId\":176,\"english\":\"牛乳\",\"chinese\":\"牛奶\"},{\"wordId\":150,\"english\":\"火曜日\",\"chinese\":\"星期二\"},{\"wordId\":169,\"english\":\"あの\",\"chinese\":\"那个（远+名词）\"},{\"wordId\":162,\"english\":\"彼ら\",\"chinese\":\"他们\"},{\"wordId\":135,\"english\":\"ただいま\",\"chinese\":\"我回来了\"},{\"wordId\":287,\"english\":\"姉\",\"chinese\":\"姐姐\"},{\"wordId\":187,\"english\":\"いちご\",\"chinese\":\"草莓\"},{\"wordId\":210,\"english\":\"公園\",\"chinese\":\"公园\"},{\"wordId\":148,\"english\":\"週\",\"chinese\":\"周\"}]', NULL, 6310, 1, '2026-04-23 12:31:18');
INSERT INTO `ai_article_log` VALUES (20, 39, 3, '校园', 'EASY', 'SHORT', 'My campus life is brief but full of learning. I must choose my classes wisely. The schedule can be busy, but I try to cope with the pressure. My days consist of lectures, study time, and meeting friends.\n\nSometimes, there is a conflict between study and rest. I cannot afford to waste time. I need to assure my family that I am doing well. When exams come, my free time will decrease.\n\nOur student congress helps with many issues. They cover topics like campus safety and event planning. Being part of this community makes my school days meaningful and bright.', '[{\"wordId\":642,\"english\":\"brief\",\"chinese\":\"简短的；摘要\"},{\"wordId\":582,\"english\":\"afford\",\"chinese\":\"买得起；承担得起\"},{\"wordId\":763,\"english\":\"decrease\",\"chinese\":\"减少；降低\"},{\"wordId\":737,\"english\":\"cope\",\"chinese\":\"处理；应付\"},{\"wordId\":674,\"english\":\"choose\",\"chinese\":\"选择；挑选\"},{\"wordId\":720,\"english\":\"consist\",\"chinese\":\"由…组成；存在于\"},{\"wordId\":612,\"english\":\"assure\",\"chinese\":\"保证；使确信\"},{\"wordId\":714,\"english\":\"conflict\",\"chinese\":\"冲突；矛盾\"},{\"wordId\":744,\"english\":\"cover\",\"chinese\":\"覆盖；包括\"},{\"wordId\":716,\"english\":\"congress\",\"chinese\":\"国会；代表大会\"}]', '我的校园生活虽然短暂，却充满了学习。我必须明智地选择课程。日程安排可能很繁忙，但我努力应对压力。我的日常包括听课、学习时间和与朋友见面。\n\n有时，学习和休息之间会产生冲突。我浪费不起时间。我需要让家人确信我过得很好。考试来临时，我的空闲时间就会减少。\n\n我们的学生会帮助解决许多问题。他们涉及校园安全和活动策划等议题。成为这个集体的一员，让我的校园生活变得有意义且充满光明。', 5800, 1, '2026-04-23 13:38:19');
INSERT INTO `ai_article_log` VALUES (21, 39, 13, '旅行', 'MEDIUM', 'MEDIUM', '先日、娘と一緒に小さな旅に出かけました。目的地は山の中にある古い町です。標高が少し**低い**場所でしたが、風がとても**涼しく**て、夏の暑さを忘れさせてくれました。町のメインストリートは観光客でにぎわっていましたが、少し路地に入ると、静かで時間がゆっくり流れているようでした。昼食は、地元で有名なレストランで**カレー**を食べました。スパイスの効いた**美味しい**カレーで、娘も大満足の様子でした。\n\n午後は、町の外れにある果物農園を訪れました。そこで新鮮な**いちご**を摘む体験ができました。真っ赤なりんごのような**いちご**は、その場で食べると格別でした。農園の主人はとても親切で、「たくさん食べてくださいね」と笑顔で言ってくれました。帰り際には、「**ごちそうさまでした**」と心からお礼を言いました。\n\n夕方、宿に戻る途中で少し雨に降られました。娘が「服が**汚い**よ」と心配そうに言うので、「**大丈夫**、宿に着いたらすぐに洗えるから」と答えました。山の天気は変わりやすいですね。宿は伝統的な日本家屋で、部屋は木の温もりで**暖かく**、とても落ち着く空間でした。窓の外には、雨上がりのきれいな夕焼けが広がっていました。\n\n短い旅行でしたが、日常を離れてゆっくり過ごせたことは、私にとっても娘にとっても良い思い出になりました。自然の中でのんびりする時間は、何よりの宝物です。またいつか、違う季節に訪れてみたいと思います。', '[{\"wordId\":187,\"english\":\"いちご\",\"chinese\":\"草莓\"},{\"wordId\":293,\"english\":\"娘\",\"chinese\":\"女儿\"},{\"wordId\":247,\"english\":\"低い\",\"chinese\":\"低的/便宜的\"},{\"wordId\":259,\"english\":\"汚い\",\"chinese\":\"脏的\"},{\"wordId\":134,\"english\":\"ごちそうさまでした\",\"chinese\":\"多谢款待\"},{\"wordId\":138,\"english\":\"大丈夫\",\"chinese\":\"没关系/没事\"},{\"wordId\":264,\"english\":\"美味しい\",\"chinese\":\"好吃的\"},{\"wordId\":190,\"english\":\"カレー\",\"chinese\":\"咖喱\"}]', '前几天，我和女儿一起进行了一次短途旅行。目的地是山中的一座古镇。虽然海拔略**低**，但山风**凉爽宜人**，让人忘却了夏日的炎热。镇上的主街游客熙攘，但只要拐进小巷，便仿佛踏入静谧缓慢的时光。午餐在当地有名的餐厅品尝了**咖喱**饭，香料浓郁的**美味**咖喱让女儿也露出了心满意足的表情。\n\n下午我们去了镇郊的果园，体验了采摘新鲜**草莓**的乐趣。那些红如苹果的**草莓**现摘现吃，滋味格外香甜。果园主人十分热情，笑着招呼我们：\"请多吃点呀！\"临走时，我们由衷地道了声\"**承蒙款待**\"。\n\n傍晚回住处时遇上一阵急雨，女儿担心地说：\"衣服都**弄脏**了\"，我安慰她：\"**没关系**，到住处马上就能洗。\"山里的天气真是多变呢。我们住的传统日式老屋，房间因木质的温润显得格外**温暖**，是个令人安心的空间。窗外铺展着雨后天晴的绮丽晚霞。\n\n这趟短暂的旅行，让我们得以从日常中抽身享受悠闲时光，对我和女儿而言都成了美好的回忆。在自然中放松身心的时刻，比任何事物都珍贵。真希望未来能在不同的季节，再次造访这个地方。', 16052, 1, '2026-04-23 13:39:42');
INSERT INTO `ai_article_log` VALUES (22, 43, 18, '校园', 'EASY', 'SHORT', 'My school is a small world. Every day, I study in the classroom. I like to study English because it is fun. I often say \"hello\" to my teacher in the morning. She smiles and says \"hello\" back.\n\nIn the computer room, I use a computer to learn new words. The computer helps me a lot. After class, I go to the library to study with my friends. We read books and practice English together.\n\nSchool is a happy place. I learn many things every day. I want to study hard and explore the big world outside.', '[{\"wordId\":802,\"english\":\"study\",\"chinese\":\"/ˈstʌdi/学习\\tStudy makes me happy.\"},{\"wordId\":799,\"english\":\"world\",\"chinese\":\"/wɜːld/\\t世界\\tWelcome to the world!\"},{\"wordId\":800,\"english\":\"computer\",\"chinese\":\"/kəmˈpjuːtər/计算机\\tI use computer every day.\"},{\"wordId\":801,\"english\":\"english\",\"chinese\":\"/ˈɪŋɡlɪʃ/英语\\tI am learning English.\"}]', '我的学校是一个小世界。每天，我都在教室里学习。我喜欢学英语，因为它很有趣。早上我常常对老师说“你好”，她微笑着回应我“你好”。\n\n在计算机房里，我用电脑学习新单词。电脑帮了我很多忙。下课后，我会和朋友们去图书馆学习。我们一起读书、练习英语。\n\n学校是个快乐的地方。我每天都能学到很多东西。我要努力学习，去探索外面的大世界。', 2168, 1, '2026-04-25 10:55:41');
INSERT INTO `ai_article_log` VALUES (23, 43, 18, '校园', 'MEDIUM', 'SHORT', 'Hello everyone. Let me share a typical day at my high school. Every morning, I say hello to my friends and then we begin to study english together. Our classroom is a small world where we explore new ideas.\n\nIn computer class, we learn how to write programs. It is challenging but fun. We also study history and science, which helps us understand the world better. After school, I often go to the library to study for exams. My favorite subject is english because I enjoy reading stories.\n\nSometimes, we work in groups to practice speaking. We use a computer to look up new words. This makes learning easier and more interesting. I hope you can study with us someday.', '[{\"wordId\":800,\"english\":\"computer\",\"chinese\":\"/kəmˈpjuːtər/计算机\\tI use computer every day.\"},{\"wordId\":802,\"english\":\"study\",\"chinese\":\"/ˈstʌdi/学习\\tStudy makes me happy.\"},{\"wordId\":801,\"english\":\"english\",\"chinese\":\"/ˈɪŋɡlɪʃ/英语\\tI am learning English.\"},{\"wordId\":799,\"english\":\"world\",\"chinese\":\"/wɜːld/\\t世界\\tWelcome to the world!\"}]', '大家好。让我分享一下我在高中的典型一天。每天早上，我都会和朋友们打招呼，然后我们一起开始学习英语。我们的教室是一个小小的世界，我们在其中探索新的想法。\n\n在计算机课上，我们学习如何编写程序。这虽然很有挑战性，但也很有趣。我们还学习历史和科学，这帮助我们更好地理解世界。放学后，我经常去图书馆为考试复习。我最喜欢的科目是英语，因为我喜欢读故事。\n\n有时候，我们会分组练习口语。我们用电脑查找生词。这让学习变得更容易、更有趣。希望有一天你们也能和我们一起学习。', 2381, 1, '2026-04-25 10:56:10');
INSERT INTO `ai_article_log` VALUES (24, 35, 3, '校园生活', 'EASY', 'SHORT', 'Every morning, I walk into our school and feel the brilliant sunshine. Our teachers often appoint a student to lead the class in reading. This simple task helps boost our confidence.One important characteristic of our school is the strong community. We learn to contribute ideas during group projects. Sometimes language can be a barrier, but our teachers help us find appropriate ways to communicate. They correct our mistakes with patience.I try to articulate my thoughts clearly in class. A good education should base on understanding, not just memorization. With hard work, every day becomes a chance to learn something new and grow together.', '[{\"wordId\":643,\"english\":\"brilliant\",\"chinese\":\"杰出的；灿烂的\"},{\"wordId\":627,\"english\":\"barrier\",\"chinese\":\"障碍；屏障\"},{\"wordId\":667,\"english\":\"characteristic\",\"chinese\":\"特征；特点\"},{\"wordId\":597,\"english\":\"appoint\",\"chinese\":\"任命；约定\"},{\"wordId\":599,\"english\":\"appropriate\",\"chinese\":\"适当的；合适的\"},{\"wordId\":738,\"english\":\"correct\",\"chinese\":\"正确的；纠正\"},{\"wordId\":731,\"english\":\"contribute\",\"chinese\":\"贡献；促成\"},{\"wordId\":605,\"english\":\"articulate\",\"chinese\":\"清晰表达；发音清晰\"},{\"wordId\":628,\"english\":\"base\",\"chinese\":\"基础；基地\"},{\"wordId\":640,\"english\":\"boost\",\"chinese\":\"促进；提升\"}]', NULL, 2410, 1, '2026-04-25 11:31:07');
INSERT INTO `ai_article_log` VALUES (25, 43, 18, 'General', 'EASY', 'SHORT', 'Hello. Welcome to the world of English. It is a big world with many people. You can study English every day. It is a good habit. You can say \"hello\" to a friend. You can also say \"hello\" to a computer. It is fun to learn new words.\n\nStart with simple words. Study a little each day. The world of English is full of new things. You can read, write, and speak. It is easy to begin. Just say \"hello\" and start your study. The computer can help you. It is a great tool for learning.\n\nRemember, every word you study makes your world bigger. English opens many doors. So, say hello to your new language. Enjoy the journey.', '[{\"wordId\":802,\"english\":\"study\",\"chinese\":\"/ˈstʌdi/学习\\tStudy makes me happy.\"},{\"wordId\":799,\"english\":\"world\",\"chinese\":\"/wɜːld/\\t世界\\tWelcome to the world!\"},{\"wordId\":801,\"english\":\"english\",\"chinese\":\"/ˈɪŋɡlɪʃ/英语\\tI am learning English.\"},{\"wordId\":800,\"english\":\"computer\",\"chinese\":\"/kəmˈpjuːtər/计算机\\tI use computer every day.\"}]', NULL, 2356, 1, '2026-04-25 11:31:37');
INSERT INTO `ai_article_log` VALUES (26, 43, 18, '旅行', 'MEDIUM', 'SHORT', 'Traveling is a wonderful way to study different cultures and languages. When you visit a new country, you can practice saying hello to locals and learn how to communicate in their native tongue. For example, if you travel to an English-speaking nation, you might use simple greetings like \"Hello, computer, world\" as a fun way to remember new phrases.\n\nExploring famous landmarks and trying local food also helps you improve your English skills naturally. You can read signs, ask for directions, and order meals while practicing vocabulary. Even a short trip can make you more confident in speaking a foreign language.\n\nRemember, every journey is a chance to study and grow. Whether you are in a bustling city or a quiet village, saying hello to people and immersing yourself in the world around you will enrich your travel experience.', '[{\"wordId\":802,\"english\":\"study\",\"chinese\":\"/ˈstʌdi/学习\\tStudy makes me happy.\"},{\"wordId\":801,\"english\":\"english\",\"chinese\":\"/ˈɪŋɡlɪʃ/英语\\tI am learning English.\"},{\"wordId\":800,\"english\":\"computer\",\"chinese\":\"/kəmˈpjuːtər/计算机\\tI use computer every day.\"},{\"wordId\":799,\"english\":\"world\",\"chinese\":\"/wɜːld/\\t世界\\tWelcome to the world!\"}]', NULL, 2659, 1, '2026-04-25 11:42:59');
INSERT INTO `ai_article_log` VALUES (27, 43, 3, '学习技巧', 'EASY', 'SHORT', 'Learning a new language is a constant journey. You need to communicate with others and practice every day. A common belief is that you must study for many hours, but this is not true. You can compress your study time into short, focused sessions. This method is a key component of success.\n\nFirst, adopt a simple plan. You can confirm your progress by writing three new words each day. Do not try to do everything at once. It is better to behave like a patient learner. A comprehensive approach means you listen, speak, and read a little every day.\n\nFinally, declare your goals to a friend. This will help you stay on track. Small steps lead to big results. Keep your learning simple and regular.', '[{\"wordId\":713,\"english\":\"confirm\",\"chinese\":\"确认；证实\"},{\"wordId\":762,\"english\":\"declare\",\"chinese\":\"宣布；声明\"},{\"wordId\":701,\"english\":\"compress\",\"chinese\":\"压缩；压紧\"},{\"wordId\":721,\"english\":\"constant\",\"chinese\":\"持续的；恒定的\"},{\"wordId\":634,\"english\":\"belief\",\"chinese\":\"信念；信仰\"},{\"wordId\":697,\"english\":\"component\",\"chinese\":\"组成部分；组件\"},{\"wordId\":690,\"english\":\"communicate\",\"chinese\":\"交流；沟通\"},{\"wordId\":700,\"english\":\"comprehensive\",\"chinese\":\"全面的；综合的\"},{\"wordId\":633,\"english\":\"behave\",\"chinese\":\"表现；举止\"},{\"wordId\":576,\"english\":\"adopt\",\"chinese\":\"采用；收养\"}]', NULL, 2350, 1, '2026-04-25 11:46:57');
INSERT INTO `ai_article_log` VALUES (28, 43, 18, '学习技巧2', 'EASY', 'SHORT', 'Hello, everyone. Today I want to share some easy study tips. First, you can say hello to English every day. Read one short story or watch a fun video. This helps your brain get used to the new language.\n\nSecond, use a computer to practice. You can find many free websites for English study. Try to write one new word each day. For example, write the word \"hello\" and say it out loud. This makes your memory stronger.\n\nFinally, do not study for too long. Just15 minutes each day is good. You can say hello to a friend in English. Small steps help you learn better. Happy study!', '[{\"wordId\":800,\"english\":\"computer\",\"chinese\":\"/kəmˈpjuːtər/计算机\\tI use computer every day.\"},{\"wordId\":801,\"english\":\"english\",\"chinese\":\"/ˈɪŋɡlɪʃ/英语\\tI am learning English.\"},{\"wordId\":802,\"english\":\"study\",\"chinese\":\"/ˈstʌdi/学习\\tStudy makes me happy.\"}]', NULL, 2209, 1, '2026-04-25 11:47:09');
INSERT INTO `ai_article_log` VALUES (29, 46, 3, '校园', 'MEDIUM', 'SHORT', 'Our campus is a place where learning and growth constantly accelerate. The library, the classrooms, and the sports field all constitute the core of our daily life. A clear goal is essential for every student to succeed, and hard work must accumulate over time to achieve it. Students often compete in various academic and athletic events. These activities help us connect with classmates and build lasting friendships. A key characteristic of our school is that the knowledge we gain is always applicable to real-world problems. No one can claim that studying here is easy, but it is certainly rewarding. Our school life consists of both challenges and joys, making it a truly memorable experience.', '[{\"wordId\":680,\"english\":\"clear\",\"chinese\":\"清楚的；清除\"},{\"wordId\":595,\"english\":\"applicable\",\"chinese\":\"适用的；合适的\"},{\"wordId\":722,\"english\":\"constitute\",\"chinese\":\"构成；组成\"},{\"wordId\":717,\"english\":\"connect\",\"chinese\":\"连接；联系\"},{\"wordId\":570,\"english\":\"accumulate\",\"chinese\":\"积累；积聚\"},{\"wordId\":693,\"english\":\"compete\",\"chinese\":\"竞争；比赛\"},{\"wordId\":677,\"english\":\"claim\",\"chinese\":\"声称；索赔\"},{\"wordId\":667,\"english\":\"characteristic\",\"chinese\":\"特征；特点\"}]', '我们的校园是一个学习和成长不断加速的地方。图书馆、教室和运动场共同构成了我们日常生活的核心。明确的目标对每位学生的成功至关重要，而勤奋努力必须日积月累才能实现目标。学生们经常参加各类学术和体育竞赛。这些活动帮助我们与同学建立联系，并缔造持久的友谊。我们学校的一个关键特点是，所学的知识始终能够应用于现实问题。没有人能说在这里学习很轻松，但确实收获颇丰。我们的校园生活既有挑战也有欢乐，使其成为一段真正难忘的经历。', 2607, 1, '2026-04-25 11:55:52');

-- ----------------------------
-- Table structure for error_book
-- ----------------------------
DROP TABLE IF EXISTS `error_book`;
CREATE TABLE `error_book`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
  `word_id` bigint NOT NULL COMMENT '单词ID（逻辑外键，关联word.id）',
  `error_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '错误类型：EN_TO_CN/CN_TO_EN/LISTEN/SPELL',
  `error_times` int NOT NULL DEFAULT 1 COMMENT '错误次数',
  `is_mastered` tinyint NOT NULL DEFAULT 0 COMMENT '是否已掌握：0-未掌握，1-已掌握',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-删除',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_word_id`(`word_id` ASC) USING BTREE,
  INDEX `idx_is_mastered`(`is_mastered` ASC) USING BTREE,
  INDEX `idx_error_type`(`error_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 69 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '错题本表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of error_book
-- ----------------------------
INSERT INTO `error_book` VALUES (1, 2, 1, 'LISTEN', 2, 0, 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `error_book` VALUES (2, 2, 10, 'SPELL', 3, 0, 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `error_book` VALUES (3, 3, 14, 'CN_TO_EN', 1, 1, 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `error_book` VALUES (9, 30, 7, 'EN_TO_CN', 1, 0, 1, '2026-04-15 10:43:24', '2026-04-15 10:43:24');
INSERT INTO `error_book` VALUES (10, 30, 8, 'EN_TO_CN', 1, 0, 1, '2026-04-15 10:43:25', '2026-04-15 10:43:25');
INSERT INTO `error_book` VALUES (11, 30, 9, 'EN_TO_CN', 1, 1, 1, '2026-04-15 10:43:26', '2026-04-15 10:43:26');
INSERT INTO `error_book` VALUES (12, 1, 7, 'EN_TO_CN', 1, 0, 1, '2026-04-15 21:49:30', '2026-04-15 21:49:30');
INSERT INTO `error_book` VALUES (13, 1, 8, 'EN_TO_CN', 1, 0, 1, '2026-04-15 21:49:38', '2026-04-15 21:49:38');
INSERT INTO `error_book` VALUES (14, 5, 85, 'EN_TO_CN', 1, 0, 0, '2026-04-15 22:24:21', '2026-04-15 22:42:09');
INSERT INTO `error_book` VALUES (15, 5, 88, 'EN_TO_CN', 1, 0, 0, '2026-04-15 22:24:42', '2026-04-15 22:42:09');
INSERT INTO `error_book` VALUES (16, 5, 89, 'EN_TO_CN', 1, 0, 0, '2026-04-15 22:24:44', '2026-04-15 22:42:09');
INSERT INTO `error_book` VALUES (17, 5, 96, 'EN_TO_CN', 1, 1, 1, '2026-04-15 22:37:52', '2026-04-15 22:37:52');
INSERT INTO `error_book` VALUES (18, 5, 101, 'CN_TO_EN', 1, 0, 0, '2026-04-15 22:39:53', '2026-04-15 22:42:09');
INSERT INTO `error_book` VALUES (19, 5, 105, 'LISTEN', 1, 0, 0, '2026-04-15 22:40:21', '2026-04-15 22:42:09');
INSERT INTO `error_book` VALUES (20, 5, 106, 'SPELL', 1, 1, 1, '2026-04-15 22:40:33', '2026-04-15 22:40:33');
INSERT INTO `error_book` VALUES (30, 33, 103, 'spelling', 3, 0, 1, '2026-04-15 21:31:45', '2026-04-15 21:31:45');
INSERT INTO `error_book` VALUES (31, 33, 202, 'meaning', 4, 0, 1, '2026-04-15 21:31:45', '2026-04-15 21:31:45');
INSERT INTO `error_book` VALUES (32, 33, 203, 'choice', 3, 0, 1, '2026-04-14 21:31:45', '2026-04-14 21:31:45');
INSERT INTO `error_book` VALUES (33, 33, 106, 'spelling', 3, 0, 1, '2026-04-13 21:31:45', '2026-04-13 21:31:45');
INSERT INTO `error_book` VALUES (34, 33, 111, 'pronunciation', 2, 0, 1, '2026-04-12 21:31:45', '2026-04-12 21:31:45');
INSERT INTO `error_book` VALUES (35, 33, 113, 'meaning', 3, 0, 1, '2026-04-11 21:31:45', '2026-04-11 21:31:45');
INSERT INTO `error_book` VALUES (36, 33, 117, 'spelling', 4, 0, 1, '2026-04-09 21:31:45', '2026-04-09 21:31:45');
INSERT INTO `error_book` VALUES (37, 33, 120, 'choice', 4, 0, 1, '2026-04-06 21:31:45', '2026-04-06 21:31:45');
INSERT INTO `error_book` VALUES (38, 33, 126, 'meaning', 4, 0, 1, '2026-03-28 21:31:45', '2026-03-28 21:31:45');
INSERT INTO `error_book` VALUES (39, 33, 129, 'spelling', 4, 0, 1, '2026-03-19 21:31:45', '2026-03-19 21:31:45');
INSERT INTO `error_book` VALUES (40, 35, 115, 'CN_TO_EN', 1, 0, 0, '2026-04-17 21:34:53', '2026-04-21 20:30:23');
INSERT INTO `error_book` VALUES (41, 35, 120, 'EN_TO_CN', 1, 0, 0, '2026-04-19 00:08:39', '2026-04-21 20:30:23');
INSERT INTO `error_book` VALUES (42, 35, 121, 'EN_TO_CN', 1, 0, 0, '2026-04-19 00:08:43', '2026-04-21 20:30:23');
INSERT INTO `error_book` VALUES (43, 35, 117, 'CN_TO_EN', 1, 0, 0, '2026-04-19 01:03:01', '2026-04-21 20:30:23');
INSERT INTO `error_book` VALUES (44, 35, 126, 'EN_TO_CN', 1, 0, 0, '2026-04-19 01:03:12', '2026-04-21 20:30:23');
INSERT INTO `error_book` VALUES (45, 35, 128, 'LISTEN', 1, 0, 0, '2026-04-19 01:03:22', '2026-04-21 20:30:23');
INSERT INTO `error_book` VALUES (46, 35, 129, 'SPELL', 1, 0, 0, '2026-04-19 01:03:30', '2026-04-21 20:30:23');
INSERT INTO `error_book` VALUES (47, 35, 132, 'EN_TO_CN', 1, 0, 0, '2026-04-20 18:22:48', '2026-04-21 20:30:23');
INSERT INTO `error_book` VALUES (48, 35, 566, 'EN_TO_CN', 1, 0, 1, '2026-04-23 08:45:47', '2026-04-23 08:45:47');
INSERT INTO `error_book` VALUES (49, 35, 567, 'CN_TO_EN', 1, 0, 1, '2026-04-23 08:45:52', '2026-04-23 08:45:52');
INSERT INTO `error_book` VALUES (50, 35, 587, 'EN_TO_CN', 1, 0, 1, '2026-04-23 08:46:49', '2026-04-23 08:46:49');
INSERT INTO `error_book` VALUES (51, 39, 120, 'EN_TO_CN', 1, 0, 1, '2026-04-23 13:40:59', '2026-04-23 13:40:59');
INSERT INTO `error_book` VALUES (52, 39, 8, 'EN_TO_CN', 1, 0, 1, '2026-04-23 13:41:07', '2026-04-23 13:41:07');
INSERT INTO `error_book` VALUES (53, 40, 8, 'EN_TO_CN', 1, 0, 1, '2026-04-24 18:07:07', '2026-04-24 18:07:07');
INSERT INTO `error_book` VALUES (54, 40, 565, 'CN_TO_EN', 1, 0, 1, '2026-04-24 18:07:14', '2026-04-24 18:07:14');
INSERT INTO `error_book` VALUES (55, 42, 8, 'EN_TO_CN', 1, 0, 1, '2026-04-25 10:43:11', '2026-04-25 10:43:11');
INSERT INTO `error_book` VALUES (56, 42, 565, 'CN_TO_EN', 1, 0, 1, '2026-04-25 10:43:18', '2026-04-25 10:43:18');
INSERT INTO `error_book` VALUES (57, 43, 7, 'EN_TO_CN', 1, 0, 1, '2026-04-25 10:53:05', '2026-04-25 10:53:05');
INSERT INTO `error_book` VALUES (58, 43, 8, 'EN_TO_CN', 1, 0, 1, '2026-04-25 10:53:10', '2026-04-25 10:53:10');
INSERT INTO `error_book` VALUES (59, 43, 9, 'EN_TO_CN', 1, 0, 1, '2026-04-25 10:53:16', '2026-04-25 10:53:16');
INSERT INTO `error_book` VALUES (60, 43, 566, 'CN_TO_EN', 1, 0, 1, '2026-04-25 10:53:25', '2026-04-25 10:53:25');
INSERT INTO `error_book` VALUES (61, 43, 567, 'LISTEN', 1, 0, 1, '2026-04-25 10:53:30', '2026-04-25 10:53:30');
INSERT INTO `error_book` VALUES (62, 43, 568, 'SPELL', 1, 0, 1, '2026-04-25 10:53:41', '2026-04-25 10:53:41');
INSERT INTO `error_book` VALUES (63, 43, 586, 'EN_TO_CN', 1, 0, 1, '2026-04-25 10:54:00', '2026-04-25 10:54:00');
INSERT INTO `error_book` VALUES (64, 46, 7, 'EN_TO_CN', 1, 0, 1, '2026-04-25 11:54:18', '2026-04-25 11:54:18');
INSERT INTO `error_book` VALUES (65, 46, 9, 'CN_TO_EN', 1, 0, 1, '2026-04-25 11:54:25', '2026-04-25 11:54:25');
INSERT INTO `error_book` VALUES (66, 46, 567, 'LISTEN', 1, 0, 1, '2026-04-25 11:54:36', '2026-04-25 11:54:36');
INSERT INTO `error_book` VALUES (67, 35, 819, 'CN_TO_EN', 1, 0, 1, '2026-04-27 22:46:20', '2026-04-27 22:46:20');
INSERT INTO `error_book` VALUES (68, 35, 820, 'LISTEN', 1, 0, 1, '2026-04-27 22:46:28', '2026-04-27 22:46:28');

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID（0表示所有用户）',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息标题',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息内容',
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读：0-未读，1-已读',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息类型：SYSTEM/ANNOUNCEMENT/AUDIT',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-删除',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_is_read`(`is_read` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_user_read_created`(`user_id` ASC, `is_read` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 70 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '站内消息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------
INSERT INTO `notification` VALUES (1, 0, '系统公告', '欢迎使用 EnglishLearningMate，登录后可永久保存学习数据。', 0, 'ANNOUNCEMENT', 1, '2026-04-14 13:05:41');
INSERT INTO `notification` VALUES (2, 2, '审核通知', '你的共享词库已进入审核队列，请耐心等待。', 0, 'AUDIT', 1, '2026-04-14 13:05:41');
INSERT INTO `notification` VALUES (3, 3, '学习提醒', '今天还有待复习单词，记得按时完成学习计划。', 0, 'SYSTEM', 1, '2026-04-14 13:05:41');
INSERT INTO `notification` VALUES (4, 5, '词库公开审核通过', '你提交公开审核的词库《测试》已通过审核，现已在共享词库广场公开展示。', 1, 'AUDIT', 1, '2026-04-15 18:37:30');
INSERT INTO `notification` VALUES (5, 1, '系统更新', '加CLAANND', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:17:18');
INSERT INTO `notification` VALUES (6, 2, '系统更新', '加CLAANND', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:17:18');
INSERT INTO `notification` VALUES (7, 3, '系统更新', '加CLAANND', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:17:18');
INSERT INTO `notification` VALUES (8, 35, '系统更新', '加CLAANND', 1, 'ANNOUNCEMENT', 1, '2026-04-17 22:17:18');
INSERT INTO `notification` VALUES (9, 1, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:47:44');
INSERT INTO `notification` VALUES (10, 2, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:47:44');
INSERT INTO `notification` VALUES (11, 3, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:47:44');
INSERT INTO `notification` VALUES (12, 35, '系统更新', '系统更新', 1, 'ANNOUNCEMENT', 1, '2026-04-17 22:47:44');
INSERT INTO `notification` VALUES (13, 1, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:48:32');
INSERT INTO `notification` VALUES (14, 2, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:48:32');
INSERT INTO `notification` VALUES (15, 3, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:48:32');
INSERT INTO `notification` VALUES (16, 35, '系统更新', '系统更新', 1, 'ANNOUNCEMENT', 1, '2026-04-17 22:48:32');
INSERT INTO `notification` VALUES (17, 1, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:59:57');
INSERT INTO `notification` VALUES (18, 2, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:59:57');
INSERT INTO `notification` VALUES (19, 3, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 22:59:57');
INSERT INTO `notification` VALUES (20, 35, '系统更新', '系统更新', 1, 'ANNOUNCEMENT', 1, '2026-04-17 22:59:57');
INSERT INTO `notification` VALUES (21, 1, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:07:56');
INSERT INTO `notification` VALUES (22, 2, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:07:56');
INSERT INTO `notification` VALUES (23, 3, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:07:56');
INSERT INTO `notification` VALUES (24, 35, '系统更新', '系统更新', 1, 'ANNOUNCEMENT', 1, '2026-04-17 23:07:56');
INSERT INTO `notification` VALUES (25, 1, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:17:35');
INSERT INTO `notification` VALUES (26, 2, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:17:35');
INSERT INTO `notification` VALUES (27, 3, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:17:35');
INSERT INTO `notification` VALUES (28, 35, '系统更新', '系统更新', 1, 'ANNOUNCEMENT', 1, '2026-04-17 23:17:35');
INSERT INTO `notification` VALUES (29, 1, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:17:57');
INSERT INTO `notification` VALUES (30, 2, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:17:57');
INSERT INTO `notification` VALUES (31, 3, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:17:57');
INSERT INTO `notification` VALUES (32, 35, '系统更新', '系统更新', 1, 'ANNOUNCEMENT', 1, '2026-04-17 23:17:57');
INSERT INTO `notification` VALUES (33, 1, '系统停服', '卷钱跑路了', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:30:40');
INSERT INTO `notification` VALUES (34, 2, '系统停服', '卷钱跑路了', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:30:40');
INSERT INTO `notification` VALUES (35, 3, '系统停服', '卷钱跑路了', 0, 'ANNOUNCEMENT', 1, '2026-04-17 23:30:40');
INSERT INTO `notification` VALUES (36, 35, '系统停服', '卷钱跑路了', 1, 'ANNOUNCEMENT', 1, '2026-04-17 23:30:40');
INSERT INTO `notification` VALUES (37, 1, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-19 01:05:21');
INSERT INTO `notification` VALUES (38, 2, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-19 01:05:21');
INSERT INTO `notification` VALUES (39, 3, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-19 01:05:21');
INSERT INTO `notification` VALUES (40, 35, '系统更新', '系统更新', 1, 'ANNOUNCEMENT', 1, '2026-04-19 01:05:21');
INSERT INTO `notification` VALUES (41, 36, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-19 01:05:21');
INSERT INTO `notification` VALUES (42, 1, '致用户的一封信', '欢迎使用万语集', 0, 'ANNOUNCEMENT', 1, '2026-04-23 14:09:16');
INSERT INTO `notification` VALUES (43, 2, '致用户的一封信', '欢迎使用万语集', 0, 'ANNOUNCEMENT', 1, '2026-04-23 14:09:16');
INSERT INTO `notification` VALUES (44, 3, '致用户的一封信', '欢迎使用万语集', 0, 'ANNOUNCEMENT', 1, '2026-04-23 14:09:16');
INSERT INTO `notification` VALUES (45, 35, '致用户的一封信', '欢迎使用万语集', 0, 'ANNOUNCEMENT', 1, '2026-04-23 14:09:16');
INSERT INTO `notification` VALUES (46, 36, '致用户的一封信', '欢迎使用万语集', 0, 'ANNOUNCEMENT', 1, '2026-04-23 14:09:16');
INSERT INTO `notification` VALUES (47, 37, '致用户的一封信', '欢迎使用万语集', 0, 'ANNOUNCEMENT', 1, '2026-04-23 14:09:16');
INSERT INTO `notification` VALUES (48, 38, '致用户的一封信', '欢迎使用万语集', 0, 'ANNOUNCEMENT', 1, '2026-04-23 14:09:16');
INSERT INTO `notification` VALUES (49, 39, '致用户的一封信', '欢迎使用万语集', 0, 'ANNOUNCEMENT', 1, '2026-04-23 14:09:16');
INSERT INTO `notification` VALUES (50, 1, '系统更新', '系统做了优化更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:00:00');
INSERT INTO `notification` VALUES (51, 2, '系统更新', '系统做了优化更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:00:00');
INSERT INTO `notification` VALUES (52, 3, '系统更新', '系统做了优化更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:00:00');
INSERT INTO `notification` VALUES (53, 35, '系统更新', '系统做了优化更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:00:00');
INSERT INTO `notification` VALUES (54, 39, '系统更新', '系统做了优化更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:00:00');
INSERT INTO `notification` VALUES (55, 41, '系统更新', '系统做了优化更新', 1, 'ANNOUNCEMENT', 1, '2026-04-25 11:00:00');
INSERT INTO `notification` VALUES (56, 42, '系统更新', '系统做了优化更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:00:00');
INSERT INTO `notification` VALUES (57, 43, '系统更新', '系统做了优化更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:00:00');
INSERT INTO `notification` VALUES (58, 44, '系统更新', '系统做了优化更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:00:00');
INSERT INTO `notification` VALUES (59, 1, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (60, 2, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (61, 3, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (62, 35, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (63, 39, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (64, 41, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (65, 42, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (66, 43, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (67, 44, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (68, 45, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');
INSERT INTO `notification` VALUES (69, 46, '系统更新', '系统更新', 0, 'ANNOUNCEMENT', 1, '2026-04-25 11:58:33');

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `admin_id` bigint NOT NULL COMMENT '管理员ID（逻辑外键，关联user.id）',
  `operation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作类型：USER_DISABLE/USER_ENABLE/WORDBANK_APPROVE等',
  `target_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '目标类型：USER/WORDBANK/SENSITIVE_WORD等',
  `target_id` bigint NOT NULL COMMENT '目标ID',
  `details` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作详情',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作IP地址',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_admin_id`(`admin_id` ASC) USING BTREE,
  INDEX `idx_operation_type`(`operation_type` ASC) USING BTREE,
  INDEX `idx_target_type_target_id`(`target_type` ASC, `target_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 73 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_log
-- ----------------------------
INSERT INTO `operation_log` VALUES (1, 1, 'WORDBANK_APPROVE', 'WORDBANK', 1, '初始化公开内置四级词库', '127.0.0.1', '2026-04-14 13:05:41');
INSERT INTO `operation_log` VALUES (2, 1, 'WORDBANK_APPROVE', 'WORDBANK', 2, '初始化公开内置六级词库', '127.0.0.1', '2026-04-14 13:05:41');
INSERT INTO `operation_log` VALUES (3, 1, 'WORDBANK_APPROVE', 'WORDBANK', 3, '初始化公开内置考研词库', '127.0.0.1', '2026-04-14 13:05:41');
INSERT INTO `operation_log` VALUES (4, 1, 'WORDBANK_APPROVE', 'WORDBANK', 8, '审核通过词库《测试》', '0:0:0:0:0:0:0:1', '2026-04-15 18:37:30');
INSERT INTO `operation_log` VALUES (5, 1, 'DISABLE_USER', 'USER', 33, '禁用用户账号（用户ID：33，用户名：test）', '0:0:0:0:0:0:0:1', '2026-04-17 00:02:32');
INSERT INTO `operation_log` VALUES (6, 1, 'DISABLE_USER', 'USER', 33, '禁用用户账号（用户ID：33，用户名：test）', '0:0:0:0:0:0:0:1', '2026-04-17 00:10:07');
INSERT INTO `operation_log` VALUES (7, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 8, '删除公共词库《测试》', '0:0:0:0:0:0:0:1', '2026-04-17 18:10:43');
INSERT INTO `operation_log` VALUES (8, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 8, '删除公共词库《测试》', '0:0:0:0:0:0:0:1', '2026-04-17 18:10:44');
INSERT INTO `operation_log` VALUES (9, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 8, '删除公共词库《测试》', '0:0:0:0:0:0:0:1', '2026-04-17 18:10:46');
INSERT INTO `operation_log` VALUES (10, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 8, '删除公共词库《测试》', '0:0:0:0:0:0:0:1', '2026-04-17 18:10:54');
INSERT INTO `operation_log` VALUES (11, 1, 'VOCABULARY_CREATE', 'VOCABULARY', 12, '发布公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-17 18:45:50');
INSERT INTO `operation_log` VALUES (12, 1, 'WORD_IMPORT', 'WORD', 12, '批量导入单词到词库《CLANNAD》，成功5条，失败0条', '0:0:0:0:0:0:0:1', '2026-04-17 20:51:39');
INSERT INTO `operation_log` VALUES (13, 1, 'CREATE', 'ANNOUNCEMENT', 0, '{\"title\":\"系统更新\",\"recipientCount\":4}', '', '2026-04-17 23:17:36');
INSERT INTO `operation_log` VALUES (14, 1, 'CREATE', 'ANNOUNCEMENT', 0, '{\"title\":\"系统更新\",\"recipientCount\":4}', '', '2026-04-17 23:17:57');
INSERT INTO `operation_log` VALUES (15, 1, 'CREATE', 'ANNOUNCEMENT', 0, '{\"title\":\"系统停服\",\"recipientCount\":4}', '', '2026-04-17 23:30:40');
INSERT INTO `operation_log` VALUES (16, 1, 'WORD_IMPORT', 'WORD', 13, '批量导入单词到词库《日语入门词库》，成功183条，失败23条', '0:0:0:0:0:0:0:1', '2026-04-19 00:08:03');
INSERT INTO `operation_log` VALUES (17, 1, 'CREATE', 'ANNOUNCEMENT', 0, '{\"title\":\"系统更新\",\"recipientCount\":5}', '', '2026-04-19 01:05:21');
INSERT INTO `operation_log` VALUES (18, 1, 'WORD_UPDATE', 'WORD', 117, '在词库《CLANNAD》中修改单词：computer', '0:0:0:0:0:0:0:1', '2026-04-20 21:58:49');
INSERT INTO `operation_log` VALUES (19, 1, 'WORD_UPDATE', 'WORD', 118, '在词库《CLANNAD》中修改单词：english', '0:0:0:0:0:0:0:1', '2026-04-20 21:59:22');
INSERT INTO `operation_log` VALUES (20, 1, 'WORD_UPDATE', 'WORD', 119, '在词库《CLANNAD》中修改单词：study', '0:0:0:0:0:0:0:1', '2026-04-20 21:59:32');
INSERT INTO `operation_log` VALUES (21, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 16:24:03');
INSERT INTO `operation_log` VALUES (22, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 16:24:21');
INSERT INTO `operation_log` VALUES (23, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 16:24:24');
INSERT INTO `operation_log` VALUES (24, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 16:54:20');
INSERT INTO `operation_log` VALUES (25, 1, 'WORD_DELETE', 'WORD', 116, '从词库《CLANNAD》中删除单词：world', '0:0:0:0:0:0:0:1', '2026-04-21 16:54:35');
INSERT INTO `operation_log` VALUES (26, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 17:12:51');
INSERT INTO `operation_log` VALUES (27, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 17:12:55');
INSERT INTO `operation_log` VALUES (28, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 17:13:09');
INSERT INTO `operation_log` VALUES (29, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 17:13:14');
INSERT INTO `operation_log` VALUES (30, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 17:14:34');
INSERT INTO `operation_log` VALUES (31, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 17:14:36');
INSERT INTO `operation_log` VALUES (32, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 17:14:39');
INSERT INTO `operation_log` VALUES (33, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 17:29:24');
INSERT INTO `operation_log` VALUES (34, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 17:29:27');
INSERT INTO `operation_log` VALUES (35, 1, 'WORD_DELETE', 'WORD', 115, '从词库《CLANNAD》中删除单词：hello', '0:0:0:0:0:0:0:1', '2026-04-21 17:35:20');
INSERT INTO `operation_log` VALUES (36, 1, 'WORD_DELETE', 'WORD', 116, '从词库《CLANNAD》中删除单词：world', '0:0:0:0:0:0:0:1', '2026-04-21 17:35:23');
INSERT INTO `operation_log` VALUES (37, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 17:51:39');
INSERT INTO `operation_log` VALUES (38, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 17:55:06');
INSERT INTO `operation_log` VALUES (39, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 17:59:28');
INSERT INTO `operation_log` VALUES (40, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 17:59:34');
INSERT INTO `operation_log` VALUES (41, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 18:02:42');
INSERT INTO `operation_log` VALUES (42, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 18:44:04');
INSERT INTO `operation_log` VALUES (43, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 19:20:49');
INSERT INTO `operation_log` VALUES (44, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 19:21:22');
INSERT INTO `operation_log` VALUES (45, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 12, '删除公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 19:41:04');
INSERT INTO `operation_log` VALUES (46, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 14, '删除公共词库《韩语入门词库》', '0:0:0:0:0:0:0:1', '2026-04-21 19:53:33');
INSERT INTO `operation_log` VALUES (47, 1, 'WORD_DELETE', 'WORD', 1, '从词库《四级核心词汇》中删除单词：ability', '0:0:0:0:0:0:0:1', '2026-04-21 20:02:26');
INSERT INTO `operation_log` VALUES (48, 1, 'WORD_DELETE', 'WORD', 1, '从词库《四级核心词汇》中删除单词：ability', '0:0:0:0:0:0:0:1', '2026-04-21 20:25:35');
INSERT INTO `operation_log` VALUES (49, 1, 'VOCABULARY_CREATE', 'VOCABULARY', 16, '发布公共词库《CLANNAD》', '0:0:0:0:0:0:0:1', '2026-04-21 20:27:32');
INSERT INTO `operation_log` VALUES (50, 1, 'WORD_IMPORT', 'WORD', 1, '批量导入单词到词库《四级核心词汇》，成功253条，失败2条', '0:0:0:0:0:0:0:1', '2026-04-21 21:39:47');
INSERT INTO `operation_log` VALUES (51, 1, 'WORD_IMPORT', 'WORD', 3, '批量导入单词到词库《考研核心词汇》，成功226条，失败0条', '0:0:0:0:0:0:0:1', '2026-04-21 21:40:11');
INSERT INTO `operation_log` VALUES (52, 1, 'CREATE', 'ANNOUNCEMENT', 0, '{\"title\":\"致用户的一封信\",\"recipientCount\":8}', '', '2026-04-23 14:09:16');
INSERT INTO `operation_log` VALUES (53, 1, 'WORD_IMPORT', 'WORD', 1, '批量导入单词到词库《四级核心词汇》，成功5条，失败0条', '0:0:0:0:0:0:0:1', '2026-04-25 10:59:12');
INSERT INTO `operation_log` VALUES (54, 1, 'CREATE', 'ANNOUNCEMENT', 0, '{\"title\":\"系统更新\",\"recipientCount\":9}', '', '2026-04-25 11:00:00');
INSERT INTO `operation_log` VALUES (55, 1, 'WORD_IMPORT', 'WORD', 1, '批量导入单词到词库《四级核心词汇》，成功0条，失败5条', '0:0:0:0:0:0:0:1', '2026-04-25 11:57:47');
INSERT INTO `operation_log` VALUES (56, 1, 'VOCABULARY_CREATE', 'VOCABULARY', 20, '发布公共词库《测试》', '0:0:0:0:0:0:0:1', '2026-04-25 11:58:09');
INSERT INTO `operation_log` VALUES (57, 1, 'WORD_IMPORT', 'WORD', 20, '批量导入单词到词库《测试》，成功5条，失败0条', '0:0:0:0:0:0:0:1', '2026-04-25 11:58:17');
INSERT INTO `operation_log` VALUES (58, 1, 'CREATE', 'ANNOUNCEMENT', 0, '{\"title\":\"系统更新\",\"recipientCount\":11}', '', '2026-04-25 11:58:33');
INSERT INTO `operation_log` VALUES (59, 1, 'WORD_UPDATE', 'WORD', 815, '在词库《测试》中修改单词：computer', '0:0:0:0:0:0:0:1', '2026-04-27 14:46:07');
INSERT INTO `operation_log` VALUES (60, 1, 'VOCABULARY_CREATE', 'VOCABULARY', 21, '发布公共词库《德语》', '0:0:0:0:0:0:0:1', '2026-04-27 14:46:45');
INSERT INTO `operation_log` VALUES (61, 1, 'VOCABULARY_DELETE', 'VOCABULARY', 21, '删除公共词库《德语》', '0:0:0:0:0:0:0:1', '2026-04-27 15:58:02');
INSERT INTO `operation_log` VALUES (62, 1, 'VOCABULARY_CREATE', 'VOCABULARY', 22, '发布公共词库《德语》', '0:0:0:0:0:0:0:1', '2026-04-27 15:58:17');
INSERT INTO `operation_log` VALUES (63, 1, 'VOCABULARY_CREATE', 'VOCABULARY', 23, '发布公共词库《德语入门》', '0:0:0:0:0:0:0:1', '2026-04-27 19:12:35');
INSERT INTO `operation_log` VALUES (64, 1, 'WORD_IMPORT', 'WORD', 23, '批量导入单词到词库《德语入门》，成功159条，失败1条', '0:0:0:0:0:0:0:1', '2026-04-27 19:31:43');
INSERT INTO `operation_log` VALUES (65, 1, 'VOCABULARY_CREATE', 'VOCABULARY', 24, '发布公共词库《法语入门》', '0:0:0:0:0:0:0:1', '2026-04-27 22:45:53');
INSERT INTO `operation_log` VALUES (66, 1, 'WORD_IMPORT', 'WORD', 24, '批量导入单词到词库《法语入门》，成功171条，失败4条', '0:0:0:0:0:0:0:1', '2026-04-27 22:48:28');
INSERT INTO `operation_log` VALUES (67, 1, 'VOCABULARY_CREATE', 'VOCABULARY', 25, '发布公共词库《西班牙语入门》', '0:0:0:0:0:0:0:1', '2026-04-27 23:14:08');
INSERT INTO `operation_log` VALUES (68, 1, 'WORD_IMPORT', 'WORD', 25, '批量导入单词到词库《西班牙语入门》，成功210条，失败1条', '0:0:0:0:0:0:0:1', '2026-04-27 23:17:47');
INSERT INTO `operation_log` VALUES (69, 1, 'WORD_IMPORT', 'WORD', 14, '批量导入单词到词库《韩语入门词库》，成功173条，失败1条', '0:0:0:0:0:0:0:1', '2026-04-27 23:27:03');
INSERT INTO `operation_log` VALUES (70, 1, 'WORD_DELETE', 'WORD', 122, '从词库《韩语入门词库》中删除单词：사랑', '0:0:0:0:0:0:0:1', '2026-04-27 23:27:10');
INSERT INTO `operation_log` VALUES (71, 1, 'WORD_DELETE', 'WORD', 123, '从词库《韩语入门词库》中删除单词：학교', '0:0:0:0:0:0:0:1', '2026-04-27 23:27:12');
INSERT INTO `operation_log` VALUES (72, 1, 'WORD_IMPORT', 'WORD', 2, '批量导入单词到词库《六级核心词汇》，成功314条，失败1条', '0:0:0:0:0:0:0:1', '2026-04-27 23:36:26');

-- ----------------------------
-- Table structure for sensitive_word
-- ----------------------------
DROP TABLE IF EXISTS `sensitive_word`;
CREATE TABLE `sensitive_word`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `word` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '敏感词',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_word`(`word` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '敏感词库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sensitive_word
-- ----------------------------
INSERT INTO `sensitive_word` VALUES (1, '暴力', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `sensitive_word` VALUES (2, '色情', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `sensitive_word` VALUES (3, '赌博', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `sensitive_word` VALUES (4, '毒品', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `sensitive_word` VALUES (5, '诈骗', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `sensitive_word` VALUES (6, '辱骂', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `sensitive_word` VALUES (7, '枪支', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `sensitive_word` VALUES (8, '违法', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `sensitive_word` VALUES (9, '恐怖主义', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `sensitive_word` VALUES (10, '仇恨言论', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '配置值',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `config_key`(`config_key` ASC) USING BTREE,
  INDEX `idx_config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'ai_base_url', 'https://api.deepseek.com', '2026-04-18 01:15:33', '2026-04-18 01:15:54');
INSERT INTO `system_config` VALUES (2, 'ai_model', 'deepseek-chat', '2026-04-18 01:15:33', '2026-04-18 01:15:54');
INSERT INTO `system_config` VALUES (3, 'ai_api_key', 'sk-6bdc7ac3e22f456eb18a6b40d45fa4b5', '2026-04-18 01:15:33', '2026-04-18 01:15:54');

-- ----------------------------
-- Table structure for translation_session
-- ----------------------------
DROP TABLE IF EXISTS `translation_session`;
CREATE TABLE `translation_session`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `session_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '会话唯一标识',
  `source_lang` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '源语言代码',
  `target_lang` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '目标语言代码',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE/ENDED',
  `duration` int NOT NULL DEFAULT 0 COMMENT '持续时长（秒）',
  `transcript` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '识别文本记录',
  `translation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '翻译文本记录',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_session_id`(`session_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '同声翻译会话表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of translation_session
-- ----------------------------
INSERT INTO `translation_session` VALUES (1, 35, 'bbae1c2be9924cc1', 'ZH', 'EN', 'ACTIVE', 0, NULL, NULL, '2026-04-27 21:35:40', '2026-04-27 21:35:40');
INSERT INTO `translation_session` VALUES (2, 35, 'b972b33c07bf406d', 'ZH', 'EN', 'ACTIVE', 0, NULL, NULL, '2026-04-27 21:36:49', '2026-04-27 21:36:49');
INSERT INTO `translation_session` VALUES (3, 35, '73247f4857c24f4d', 'ZH', 'EN', 'ACTIVE', 0, NULL, NULL, '2026-04-27 21:37:21', '2026-04-27 21:37:21');
INSERT INTO `translation_session` VALUES (4, 35, 'feed89f6d91f45fb', 'ZH', 'EN', 'ACTIVE', 0, NULL, NULL, '2026-04-27 22:04:17', '2026-04-27 22:04:17');
INSERT INTO `translation_session` VALUES (5, 35, 'a4c773ec03054ef1', 'ZH', 'EN', 'ACTIVE', 0, NULL, NULL, '2026-04-27 22:05:28', '2026-04-27 22:05:28');
INSERT INTO `translation_session` VALUES (6, 35, 'a3a8bf78ff154bc3', 'ZH', 'EN', 'ACTIVE', 0, NULL, NULL, '2026-04-27 22:05:43', '2026-04-27 22:05:43');
INSERT INTO `translation_session` VALUES (7, 35, '17b5cdc5526f49be', 'ZH', 'EN', 'ACTIVE', 0, NULL, NULL, '2026-04-27 22:20:13', '2026-04-27 22:20:13');
INSERT INTO `translation_session` VALUES (8, 35, '6e6675de471f4b67', 'ZH', 'EN', 'ACTIVE', 0, NULL, NULL, '2026-04-27 22:41:49', '2026-04-27 22:41:49');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码（BCrypt加密）',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USER' COMMENT '角色：GUEST/USER/ADMIN',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-禁用/删除',
  `login_fail_count` int NOT NULL DEFAULT 0 COMMENT '登录失败次数',
  `lock_time` datetime NULL DEFAULT NULL COMMENT '账号锁定时间',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 47 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '$2a$10$osTmHQaHBRJqgtA29QP5DOoN2Yej4gjxcwIizyH6GCRqjJGO4lLdq', 'admin@example.com', NULL, NULL, '系统管理员', 'ADMIN', 1, 0, NULL, 20, '2026-04-14 13:05:41', '2026-04-15 18:36:50');
INSERT INTO `user` VALUES (2, 'user1', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'user1@example.com', NULL, NULL, '测试用户1', 'USER', 1, 9, '2026-04-16 17:42:14', 9, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `user` VALUES (3, 'user2', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'user2@example.com', NULL, NULL, '测试用户2', 'USER', 1, 2, NULL, 2, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `user` VALUES (35, 'test', '$2a$10$OaPfYOD7apqX/Go47iGLreForO/E4LZqNHTut1TFqW9eHOgIibweC', '123343@qq.com', NULL, '/uploads/avatars/avatar_35_e485ca0994a045abad5284d4296d8062.jpg', '可可', 'USER', 1, 0, NULL, 34, '2026-04-17 01:18:22', '2026-04-25 08:43:09');
INSERT INTO `user` VALUES (39, 'Nahida', '$2a$10$CdMRk3pPI9CXLuxZDf.EmeCRyhNC2Kc9F7Je7UD8V2RWtWTJM1j.2', '1233433@qq.com', NULL, '/uploads/avatars/avatar_39_baa7ea3751574375bcfb9e706de0acd5.png', '纳西妲', 'USER', 1, 0, NULL, 7, '2026-04-21 22:10:39', '2026-04-21 22:10:39');
INSERT INTO `user` VALUES (41, 'FuFu', '$2a$10$GNg02Cyu3F7G59lxJjP4u.kDy2YGJlwctiLSZdpqhsL4y3tjM3hTy', 'fufu@163.com', NULL, '/uploads/avatars/avatar_41_48b05fbe4dce43dba2ce39461c2d86a5.png', '芙宁娜', 'USER', 1, 0, NULL, 5, '2026-04-25 07:44:04', '2026-04-25 11:57:15');
INSERT INTO `user` VALUES (42, 'Xiaoxi', '$2a$10$MNqIBmmRmJyTb15RZRqZ9Oe7orWFPVGozFL8VVTRG7b5qaIOFlU1K', 'Xiaoxi123456@163.com', NULL, '/uploads/avatars/avatar_42_6a242cc0895946438f30ff576e6036ff.jpg', '小溪', 'USER', 1, 0, NULL, 3, '2026-04-25 10:42:13', '2026-04-25 10:42:13');
INSERT INTO `user` VALUES (43, 'XiaYu', '$2a$10$HumtBVLj7SJrY7PfnzXQyuiSAgAYlUWkkbV7CYsfNoKqcxIII1uwK', 'XiaYu@163.com', NULL, '/uploads/avatars/avatar_43_e8fe0a27cef34a33ab2f5fdc85795c83.png', '夏雨', 'USER', 1, 0, NULL, 5, '2026-04-25 10:51:44', '2026-04-25 10:51:44');
INSERT INTO `user` VALUES (44, 'guest_af509ec50588', '$2a$10$BLH5EGtPeKnlWUt4LRYumebe/5.u5LVpDxKa4KPfcipmrbiGrIDDG', 'guest_af509ec50588@guest.local', NULL, NULL, '游客af509e', 'GUEST', 1, 0, NULL, 0, '2026-04-25 10:56:50', '2026-04-25 10:56:50');
INSERT INTO `user` VALUES (45, 'guest_3d7535d86c95', '$2a$10$qpEBGln6Xa.aW/0qy1eACeIobcwjlhUGuxy8tiPf3WkULL2GixuO2', 'guest_3d7535d86c95@guest.local', NULL, NULL, '游客3d7535', 'GUEST', 1, 0, NULL, 0, '2026-04-25 11:52:11', '2026-04-25 11:52:11');
INSERT INTO `user` VALUES (46, 'xiaohua', '$2a$10$dvDzZHqZhyrsnDF1Nse3R.ErJqLOMOH2YdBr63hGEJTDsR/pnq7ly', 'huatanx@163.com', NULL, '/uploads/avatars/avatar_46_326392e1bd314c9183ff9bc633b43ae7.jpg', '花田汐', 'USER', 1, 0, NULL, 3, '2026-04-25 11:53:28', '2026-04-25 11:53:28');

-- ----------------------------
-- Table structure for user_quota
-- ----------------------------
DROP TABLE IF EXISTS `user_quota`;
CREATE TABLE `user_quota`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
  `quota_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配额类型：AI_ARTICLE/EXPORT',
  `total_quota` int NOT NULL DEFAULT 5 COMMENT '总配额',
  `used_count` int NOT NULL DEFAULT 0 COMMENT '已使用次数',
  `reset_time` datetime NOT NULL COMMENT '重置时间（每日0点）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_quota_reset`(`user_id` ASC, `quota_type` ASC, `reset_time` ASC) USING BTREE,
  INDEX `idx_user_id_quota_type`(`user_id` ASC, `quota_type` ASC) USING BTREE,
  INDEX `idx_reset_time`(`reset_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户每日配额表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_quota
-- ----------------------------
INSERT INTO `user_quota` VALUES (1, 2, 'AI_ARTICLE', 5, 1, '2026-04-14 00:00:00', '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `user_quota` VALUES (2, 2, 'EXPORT', 3, 0, '2026-04-14 00:00:00', '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `user_quota` VALUES (3, 3, 'AI_ARTICLE', 5, 1, '2026-04-14 00:00:00', '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `user_quota` VALUES (4, 3, 'EXPORT', 3, 0, '2026-04-14 00:00:00', '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `user_quota` VALUES (5, 5, 'AI_ARTICLE', 5, 4, '2026-04-15 00:00:00', '2026-04-15 08:52:40', '2026-04-15 08:52:40');
INSERT INTO `user_quota` VALUES (6, 30, 'AI_ARTICLE', 5, 2, '2026-04-15 00:00:00', '2026-04-15 10:43:31', '2026-04-15 10:43:31');
INSERT INTO `user_quota` VALUES (7, 30, 'EXPORT', 3, 1, '2026-04-15 00:00:00', '2026-04-15 17:44:28', '2026-04-15 17:44:28');
INSERT INTO `user_quota` VALUES (8, 5, 'EXPORT', 3, 0, '2026-04-15 00:00:00', '2026-04-15 18:31:33', '2026-04-15 18:31:33');
INSERT INTO `user_quota` VALUES (9, 1, 'EXPORT', 3, 0, '2026-04-15 00:00:00', '2026-04-15 18:37:14', '2026-04-15 18:37:14');
INSERT INTO `user_quota` VALUES (10, 33, 'AI_ARTICLE', 5, 0, '2026-04-16 00:00:00', '2026-04-16 19:42:03', '2026-04-16 19:42:03');
INSERT INTO `user_quota` VALUES (11, 35, 'AI_ARTICLE', 5, 0, '2026-04-17 00:00:00', '2026-04-17 13:16:15', '2026-04-17 13:16:15');
INSERT INTO `user_quota` VALUES (12, 35, 'AI_ARTICLE', 5, 2, '2026-04-18 00:00:00', '2026-04-18 00:48:17', '2026-04-18 00:48:17');
INSERT INTO `user_quota` VALUES (13, 1, 'AI_ARTICLE', 5, 0, '2026-04-18 00:00:00', '2026-04-18 01:19:52', '2026-04-18 01:19:52');
INSERT INTO `user_quota` VALUES (14, 35, 'AI_ARTICLE', 5, 3, '2026-04-19 00:00:00', '2026-04-19 00:09:39', '2026-04-19 00:18:55');
INSERT INTO `user_quota` VALUES (15, 35, 'AI_ARTICLE', 5, 0, '2026-04-21 00:00:00', '2026-04-21 15:04:07', '2026-04-21 15:04:07');
INSERT INTO `user_quota` VALUES (16, 35, 'AI_ARTICLE', 30, 0, '2026-04-22 00:00:00', '2026-04-22 19:22:46', '2026-04-22 19:22:46');
INSERT INTO `user_quota` VALUES (17, 35, 'AI_ARTICLE', 30, 1, '2026-04-23 00:00:00', '2026-04-23 08:46:25', '2026-04-23 12:31:11');
INSERT INTO `user_quota` VALUES (18, 39, 'AI_ARTICLE', 30, 2, '2026-04-23 00:00:00', '2026-04-23 13:37:53', '2026-04-23 13:39:25');
INSERT INTO `user_quota` VALUES (19, 43, 'AI_ARTICLE', 30, 6, '2026-04-25 00:00:00', '2026-04-25 10:55:17', '2026-04-25 11:47:06');
INSERT INTO `user_quota` VALUES (20, 39, 'AI_ARTICLE', 30, 0, '2026-04-25 00:00:00', '2026-04-25 10:57:56', '2026-04-25 10:57:56');
INSERT INTO `user_quota` VALUES (21, 41, 'AI_ARTICLE', 30, 0, '2026-04-25 00:00:00', '2026-04-25 11:04:39', '2026-04-25 11:04:39');
INSERT INTO `user_quota` VALUES (22, 35, 'AI_ARTICLE', 30, 1, '2026-04-25 00:00:00', '2026-04-25 11:30:37', '2026-04-25 11:31:04');
INSERT INTO `user_quota` VALUES (23, 46, 'AI_ARTICLE', 30, 1, '2026-04-25 00:00:00', '2026-04-25 11:55:39', '2026-04-25 11:55:49');
INSERT INTO `user_quota` VALUES (24, 35, 'AI_ARTICLE', 30, 0, '2026-04-27 00:00:00', '2026-04-27 22:45:32', '2026-04-27 22:45:32');

-- ----------------------------
-- Table structure for user_study_plan
-- ----------------------------
DROP TABLE IF EXISTS `user_study_plan`;
CREATE TABLE `user_study_plan`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `study_session_size` int NOT NULL DEFAULT 20 COMMENT '单次学习题量',
  `allow_same_day_review` tinyint NOT NULL DEFAULT 1 COMMENT '是否允许当天继续复习',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户学习计划表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_study_plan
-- ----------------------------
INSERT INTO `user_study_plan` VALUES (1, 5, 20, 1, '2026-04-15 22:21:24', '2026-04-15 22:21:24');
INSERT INTO `user_study_plan` VALUES (2, 32, 20, 1, '2026-04-16 17:37:15', '2026-04-16 17:37:15');
INSERT INTO `user_study_plan` VALUES (3, 1, 20, 1, '2026-04-16 17:43:23', '2026-04-16 17:43:23');
INSERT INTO `user_study_plan` VALUES (4, 33, 20, 1, '2026-04-16 17:44:12', '2026-04-16 17:44:12');
INSERT INTO `user_study_plan` VALUES (5, 35, 20, 1, '2026-04-17 01:18:30', '2026-04-17 01:18:30');
INSERT INTO `user_study_plan` VALUES (6, 2, 20, 1, '2026-04-18 10:11:31', '2026-04-18 10:11:31');
INSERT INTO `user_study_plan` VALUES (7, 3, 20, 1, '2026-04-18 10:11:33', '2026-04-18 10:11:33');
INSERT INTO `user_study_plan` VALUES (8, 36, 20, 1, '2026-04-18 22:54:30', '2026-04-18 22:54:30');
INSERT INTO `user_study_plan` VALUES (9, 37, 20, 1, '2026-04-19 20:36:24', '2026-04-19 20:36:24');
INSERT INTO `user_study_plan` VALUES (10, 38, 20, 1, '2026-04-20 09:52:24', '2026-04-20 09:52:24');
INSERT INTO `user_study_plan` VALUES (11, 39, 20, 1, '2026-04-21 22:10:51', '2026-04-21 22:10:51');
INSERT INTO `user_study_plan` VALUES (12, 40, 20, 1, '2026-04-24 18:06:22', '2026-04-24 18:06:22');
INSERT INTO `user_study_plan` VALUES (13, 41, 20, 1, '2026-04-25 07:44:17', '2026-04-25 07:44:17');
INSERT INTO `user_study_plan` VALUES (14, 42, 20, 1, '2026-04-25 10:42:23', '2026-04-25 10:42:23');
INSERT INTO `user_study_plan` VALUES (15, 43, 20, 1, '2026-04-25 10:51:57', '2026-04-25 10:51:57');
INSERT INTO `user_study_plan` VALUES (16, 44, 20, 1, '2026-04-25 10:56:50', '2026-04-25 10:56:50');
INSERT INTO `user_study_plan` VALUES (17, 45, 20, 1, '2026-04-25 11:52:11', '2026-04-25 11:52:11');
INSERT INTO `user_study_plan` VALUES (18, 46, 20, 1, '2026-04-25 11:53:42', '2026-04-25 11:53:42');

-- ----------------------------
-- Table structure for user_study_record
-- ----------------------------
DROP TABLE IF EXISTS `user_study_record`;
CREATE TABLE `user_study_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
  `word_bank_id` bigint NOT NULL COMMENT '词库ID（逻辑外键，关联word_bank.id）',
  `word_id` bigint NOT NULL COMMENT '单词ID（逻辑外键，关联word.id）',
  `study_mode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学习模式：EN_TO_CN/CN_TO_EN/LISTEN/SPELL',
  `correct_count` int NOT NULL DEFAULT 0 COMMENT '正确次数',
  `wrong_count` int NOT NULL DEFAULT 0 COMMENT '错误次数',
  `next_review_time` datetime NULL DEFAULT NULL COMMENT '下次复习时间',
  `review_count` int NOT NULL DEFAULT 0 COMMENT '复习次数',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-学习中，2-已掌握',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id_word_bank_id`(`user_id` ASC, `word_bank_id` ASC) USING BTREE,
  INDEX `idx_next_review_time`(`next_review_time` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_usr_bank_status_review`(`user_id` ASC, `word_bank_id` ASC, `status` ASC, `next_review_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 508 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户学习记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_study_record
-- ----------------------------
INSERT INTO `user_study_record` VALUES (1, 2, 1, 1, 'EN_TO_CN', 2, 1, '2026-04-15 13:05:41', 3, 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `user_study_record` VALUES (2, 2, 4, 10, 'SPELL', 1, 2, '2026-04-16 13:05:41', 3, 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `user_study_record` VALUES (3, 3, 6, 14, 'CN_TO_EN', 3, 0, '2026-04-18 13:05:41', 3, 2, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `user_study_record` VALUES (4, 5, 8, 82, 'EN_TO_CN', 2, 0, '2026-04-17 22:23:55', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (5, 5, 8, 83, 'EN_TO_CN', 1, 1, '2026-04-16 22:24:02', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (6, 5, 8, 84, 'EN_TO_CN', 2, 0, '2026-04-17 22:24:06', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (7, 5, 8, 85, 'EN_TO_CN', 0, 2, '2026-04-16 22:24:21', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (8, 5, 8, 86, 'EN_TO_CN', 2, 0, '2026-04-17 22:24:24', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (9, 5, 8, 87, 'EN_TO_CN', 2, 0, '2026-04-17 22:24:30', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (10, 5, 8, 88, 'EN_TO_CN', 0, 1, '2026-04-16 22:24:42', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (11, 5, 8, 89, 'EN_TO_CN', 0, 1, '2026-04-16 22:24:44', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (12, 5, 8, 90, 'EN_TO_CN', 2, 0, '2026-04-17 22:24:49', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (13, 5, 8, 91, 'EN_TO_CN', 2, 0, '2026-04-17 22:24:51', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (14, 5, 8, 92, 'CN_TO_EN', 2, 0, '2026-04-17 22:26:04', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (15, 5, 8, 93, 'CN_TO_EN', 2, 0, '2026-04-17 22:26:13', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (16, 5, 8, 94, 'EN_TO_CN', 2, 0, '2026-04-17 22:37:43', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (17, 5, 8, 95, 'EN_TO_CN', 2, 0, '2026-04-17 22:37:48', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (18, 5, 8, 96, 'EN_TO_CN', 0, 1, '2026-04-16 22:37:52', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (19, 5, 8, 97, 'EN_TO_CN', 2, 0, '2026-04-17 22:37:58', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (20, 5, 8, 98, 'EN_TO_CN', 2, 0, '2026-04-17 22:39:40', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (21, 5, 8, 99, 'EN_TO_CN', 2, 0, '2026-04-17 22:39:44', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (22, 5, 8, 100, 'CN_TO_EN', 2, 0, '2026-04-17 22:39:48', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (23, 5, 8, 101, 'CN_TO_EN', 0, 1, '2026-04-16 22:39:53', 2, 1, '2026-04-14 21:10:43', '2026-04-14 21:10:43');
INSERT INTO `user_study_record` VALUES (24, 5, 8, 102, 'LISTEN', 2, 0, '2026-04-17 22:40:03', 2, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (25, 5, 8, 103, 'LISTEN', 2, 0, '2026-04-17 22:40:09', 2, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (26, 5, 8, 104, 'LISTEN', 2, 0, '2026-04-17 22:40:13', 2, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (27, 5, 8, 105, 'LISTEN', 0, 1, '2026-04-16 22:40:21', 2, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (28, 5, 8, 106, 'SPELL', 0, 1, '2026-04-16 22:40:33', 2, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (29, 5, 8, 107, 'SPELL', 2, 0, '2026-04-17 22:40:42', 2, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (30, 5, 8, 108, 'CN_TO_EN', 1, 0, '2026-04-15 21:54:11', 1, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (31, 5, 8, 109, 'CN_TO_EN', 1, 0, '2026-04-15 21:54:11', 1, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (32, 5, 8, 110, 'CN_TO_EN', 1, 0, '2026-04-15 21:54:15', 1, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (33, 5, 8, 111, 'CN_TO_EN', 1, 0, '2026-04-15 21:54:15', 1, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (34, 5, 8, 112, 'CN_TO_EN', 1, 0, '2026-04-15 21:54:15', 1, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (35, 5, 8, 113, 'CN_TO_EN', 1, 0, '2026-04-15 21:54:16', 1, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (36, 5, 8, 114, 'CN_TO_EN', 1, 0, '2026-04-15 21:54:16', 1, 1, '2026-04-14 21:11:27', '2026-04-14 21:11:27');
INSERT INTO `user_study_record` VALUES (37, 22, 1, 1, 'EN_TO_CN', 0, 0, '2026-04-14 21:26:15', 0, 1, '2026-04-14 21:26:15', '2026-04-14 21:26:15');
INSERT INTO `user_study_record` VALUES (38, 22, 1, 2, 'EN_TO_CN', 0, 0, '2026-04-14 21:26:15', 0, 1, '2026-04-14 21:26:15', '2026-04-14 21:26:15');
INSERT INTO `user_study_record` VALUES (39, 22, 1, 3, 'EN_TO_CN', 0, 0, '2026-04-14 21:26:15', 0, 1, '2026-04-14 21:26:15', '2026-04-14 21:26:15');
INSERT INTO `user_study_record` VALUES (40, 23, 1, 1, 'EN_TO_CN', 0, 0, '2026-04-14 21:26:21', 0, 1, '2026-04-14 21:26:21', '2026-04-14 21:26:21');
INSERT INTO `user_study_record` VALUES (41, 23, 1, 2, 'EN_TO_CN', 0, 0, '2026-04-14 21:26:21', 0, 1, '2026-04-14 21:26:21', '2026-04-14 21:26:21');
INSERT INTO `user_study_record` VALUES (42, 23, 1, 3, 'EN_TO_CN', 0, 0, '2026-04-14 21:26:21', 0, 1, '2026-04-14 21:26:21', '2026-04-14 21:26:21');
INSERT INTO `user_study_record` VALUES (43, 24, 1, 1, 'EN_TO_CN', 1, 0, '2026-04-15 21:27:01', 1, 1, '2026-04-14 21:27:01', '2026-04-14 21:27:01');
INSERT INTO `user_study_record` VALUES (44, 24, 1, 2, 'EN_TO_CN', 0, 0, '2026-04-14 21:27:01', 0, 1, '2026-04-14 21:27:01', '2026-04-14 21:27:01');
INSERT INTO `user_study_record` VALUES (45, 24, 1, 3, 'EN_TO_CN', 0, 0, '2026-04-14 21:27:01', 0, 1, '2026-04-14 21:27:01', '2026-04-14 21:27:01');
INSERT INTO `user_study_record` VALUES (46, 5, 3, 7, 'EN_TO_CN', 0, 1, '2026-04-16 08:29:55', 1, 1, '2026-04-14 21:54:26', '2026-04-14 21:54:26');
INSERT INTO `user_study_record` VALUES (47, 5, 3, 8, 'EN_TO_CN', 0, 1, '2026-04-16 08:29:56', 1, 1, '2026-04-14 21:54:26', '2026-04-14 21:54:26');
INSERT INTO `user_study_record` VALUES (48, 5, 3, 9, 'EN_TO_CN', 0, 1, '2026-04-16 08:29:58', 1, 1, '2026-04-14 21:54:26', '2026-04-14 21:54:26');
INSERT INTO `user_study_record` VALUES (49, 5, 2, 4, 'EN_TO_CN', 0, 0, '2026-04-14 21:54:28', 0, 1, '2026-04-14 21:54:28', '2026-04-14 21:54:28');
INSERT INTO `user_study_record` VALUES (50, 5, 2, 5, 'EN_TO_CN', 0, 0, '2026-04-14 21:54:28', 0, 1, '2026-04-14 21:54:28', '2026-04-14 21:54:28');
INSERT INTO `user_study_record` VALUES (51, 5, 2, 6, 'EN_TO_CN', 0, 0, '2026-04-14 21:54:28', 0, 1, '2026-04-14 21:54:28', '2026-04-14 21:54:28');
INSERT INTO `user_study_record` VALUES (52, 5, 1, 1, 'EN_TO_CN', 0, 0, '2026-04-14 21:54:29', 0, 1, '2026-04-14 21:54:29', '2026-04-14 21:54:29');
INSERT INTO `user_study_record` VALUES (53, 5, 1, 2, 'EN_TO_CN', 0, 0, '2026-04-14 21:54:29', 0, 1, '2026-04-14 21:54:29', '2026-04-14 21:54:29');
INSERT INTO `user_study_record` VALUES (54, 5, 1, 3, 'EN_TO_CN', 0, 0, '2026-04-14 21:54:29', 0, 1, '2026-04-14 21:54:29', '2026-04-14 21:54:29');
INSERT INTO `user_study_record` VALUES (55, 28, 3, 7, 'EN_TO_CN', 0, 0, '2026-04-15 00:25:56', 0, 1, '2026-04-15 00:25:56', '2026-04-15 00:25:56');
INSERT INTO `user_study_record` VALUES (56, 28, 3, 8, 'EN_TO_CN', 0, 0, '2026-04-15 00:25:56', 0, 1, '2026-04-15 00:25:56', '2026-04-15 00:25:56');
INSERT INTO `user_study_record` VALUES (57, 28, 3, 9, 'EN_TO_CN', 0, 0, '2026-04-15 00:25:56', 0, 1, '2026-04-15 00:25:56', '2026-04-15 00:25:56');
INSERT INTO `user_study_record` VALUES (58, 29, 3, 7, 'EN_TO_CN', 0, 0, '2026-04-15 10:42:13', 0, 1, '2026-04-15 10:42:13', '2026-04-15 10:42:13');
INSERT INTO `user_study_record` VALUES (59, 29, 3, 8, 'EN_TO_CN', 0, 0, '2026-04-15 10:42:13', 0, 1, '2026-04-15 10:42:13', '2026-04-15 10:42:13');
INSERT INTO `user_study_record` VALUES (60, 29, 3, 9, 'EN_TO_CN', 0, 0, '2026-04-15 10:42:13', 0, 1, '2026-04-15 10:42:13', '2026-04-15 10:42:13');
INSERT INTO `user_study_record` VALUES (61, 30, 3, 7, 'EN_TO_CN', 0, 1, '2026-04-16 10:43:24', 1, 1, '2026-04-15 10:43:19', '2026-04-15 10:43:19');
INSERT INTO `user_study_record` VALUES (62, 30, 3, 8, 'EN_TO_CN', 0, 1, '2026-04-16 10:43:25', 1, 1, '2026-04-15 10:43:19', '2026-04-15 10:43:19');
INSERT INTO `user_study_record` VALUES (63, 30, 3, 9, 'EN_TO_CN', 0, 1, '2026-04-16 10:43:26', 1, 1, '2026-04-15 10:43:19', '2026-04-15 10:43:19');
INSERT INTO `user_study_record` VALUES (64, 30, 2, 4, 'EN_TO_CN', 0, 0, '2026-04-15 11:02:14', 0, 1, '2026-04-15 11:02:14', '2026-04-15 11:02:14');
INSERT INTO `user_study_record` VALUES (65, 30, 2, 5, 'EN_TO_CN', 0, 0, '2026-04-15 11:02:14', 0, 1, '2026-04-15 11:02:14', '2026-04-15 11:02:14');
INSERT INTO `user_study_record` VALUES (66, 30, 2, 6, 'EN_TO_CN', 0, 0, '2026-04-15 11:02:14', 0, 1, '2026-04-15 11:02:14', '2026-04-15 11:02:14');
INSERT INTO `user_study_record` VALUES (67, 30, 1, 1, 'EN_TO_CN', 0, 0, '2026-04-15 17:46:12', 0, 1, '2026-04-15 17:46:12', '2026-04-15 17:46:12');
INSERT INTO `user_study_record` VALUES (68, 30, 1, 2, 'EN_TO_CN', 0, 0, '2026-04-15 17:46:12', 0, 1, '2026-04-15 17:46:12', '2026-04-15 17:46:12');
INSERT INTO `user_study_record` VALUES (69, 30, 1, 3, 'EN_TO_CN', 0, 0, '2026-04-15 17:46:12', 0, 1, '2026-04-15 17:46:12', '2026-04-15 17:46:12');
INSERT INTO `user_study_record` VALUES (70, 1, 3, 7, 'EN_TO_CN', 0, 1, '2026-04-16 21:49:30', 1, 1, '2026-04-15 18:37:14', '2026-04-15 18:37:14');
INSERT INTO `user_study_record` VALUES (71, 1, 3, 8, 'EN_TO_CN', 0, 1, '2026-04-16 21:49:38', 1, 1, '2026-04-15 18:37:14', '2026-04-15 18:37:14');
INSERT INTO `user_study_record` VALUES (72, 1, 3, 9, 'EN_TO_CN', 1, 0, '2026-04-16 21:49:41', 1, 1, '2026-04-15 18:37:14', '2026-04-15 18:37:14');
INSERT INTO `user_study_record` VALUES (106, 33, 1, 101, 'spelling', 8, 2, '2026-04-17 21:31:45', 3, 1, '2026-04-16 21:31:45', '2026-04-16 21:31:45');
INSERT INTO `user_study_record` VALUES (107, 33, 1, 102, 'choice', 9, 1, '2026-04-18 21:31:45', 5, 1, '2026-04-16 21:31:45', '2026-04-16 21:31:45');
INSERT INTO `user_study_record` VALUES (108, 33, 1, 103, 'spelling', 7, 3, '2026-04-17 21:31:45', 2, 1, '2026-04-16 21:31:45', '2026-04-16 21:31:45');
INSERT INTO `user_study_record` VALUES (109, 33, 2, 201, 'choice', 10, 0, '2026-04-19 21:31:45', 4, 1, '2026-04-16 21:31:45', '2026-04-16 21:31:45');
INSERT INTO `user_study_record` VALUES (110, 33, 2, 202, 'spelling', 6, 4, '2026-04-16 21:31:45', 1, 1, '2026-04-16 21:31:45', '2026-04-16 21:31:45');
INSERT INTO `user_study_record` VALUES (111, 33, 1, 104, 'choice', 9, 1, '2026-04-18 21:31:45', 3, 1, '2026-04-15 21:31:45', '2026-04-15 21:31:45');
INSERT INTO `user_study_record` VALUES (112, 33, 1, 105, 'spelling', 8, 2, '2026-04-17 21:31:45', 2, 1, '2026-04-15 21:31:45', '2026-04-15 21:31:45');
INSERT INTO `user_study_record` VALUES (113, 33, 2, 203, 'choice', 7, 3, '2026-04-16 21:31:45', 1, 1, '2026-04-15 21:31:45', '2026-04-15 21:31:45');
INSERT INTO `user_study_record` VALUES (114, 33, 1, 106, 'spelling', 9, 1, '2026-04-18 21:31:45', 4, 1, '2026-04-14 21:31:45', '2026-04-14 21:31:45');
INSERT INTO `user_study_record` VALUES (115, 33, 1, 107, 'choice', 8, 2, '2026-04-19 21:31:45', 3, 1, '2026-04-14 21:31:45', '2026-04-14 21:31:45');
INSERT INTO `user_study_record` VALUES (116, 33, 2, 204, 'spelling', 10, 0, '2026-04-20 21:31:45', 5, 1, '2026-04-14 21:31:45', '2026-04-14 21:31:45');
INSERT INTO `user_study_record` VALUES (117, 33, 2, 205, 'choice', 6, 4, '2026-04-16 21:31:45', 2, 1, '2026-04-14 21:31:45', '2026-04-14 21:31:45');
INSERT INTO `user_study_record` VALUES (118, 33, 1, 108, 'choice', 7, 3, '2026-04-16 21:31:45', 1, 1, '2026-04-13 21:31:45', '2026-04-13 21:31:45');
INSERT INTO `user_study_record` VALUES (119, 33, 1, 109, 'spelling', 9, 1, '2026-04-17 21:31:45', 3, 1, '2026-04-13 21:31:45', '2026-04-13 21:31:45');
INSERT INTO `user_study_record` VALUES (120, 33, 2, 206, 'choice', 8, 2, '2026-04-18 21:31:45', 4, 1, '2026-04-13 21:31:45', '2026-04-13 21:31:45');
INSERT INTO `user_study_record` VALUES (121, 33, 1, 110, 'spelling', 10, 0, '2026-04-19 21:31:45', 5, 1, '2026-04-12 21:31:45', '2026-04-12 21:31:45');
INSERT INTO `user_study_record` VALUES (122, 33, 1, 111, 'choice', 8, 2, '2026-04-18 21:31:45', 3, 1, '2026-04-12 21:31:45', '2026-04-12 21:31:45');
INSERT INTO `user_study_record` VALUES (123, 33, 2, 207, 'spelling', 9, 1, '2026-04-20 21:31:45', 4, 1, '2026-04-12 21:31:45', '2026-04-12 21:31:45');
INSERT INTO `user_study_record` VALUES (124, 33, 1, 112, 'choice', 7, 3, '2026-04-16 21:31:45', 2, 1, '2026-04-11 21:31:45', '2026-04-11 21:31:45');
INSERT INTO `user_study_record` VALUES (125, 33, 1, 113, 'spelling', 8, 2, '2026-04-17 21:31:45', 3, 1, '2026-04-11 21:31:45', '2026-04-11 21:31:45');
INSERT INTO `user_study_record` VALUES (126, 33, 2, 208, 'choice', 9, 1, '2026-04-19 21:31:45', 4, 1, '2026-04-10 21:31:45', '2026-04-10 21:31:45');
INSERT INTO `user_study_record` VALUES (127, 33, 2, 209, 'spelling', 6, 4, '2026-04-16 21:31:45', 1, 1, '2026-04-10 21:31:45', '2026-04-10 21:31:45');
INSERT INTO `user_study_record` VALUES (128, 33, 1, 114, 'choice', 8, 2, '2026-04-18 21:31:45', 3, 1, '2026-04-09 21:31:45', '2026-04-09 21:31:45');
INSERT INTO `user_study_record` VALUES (129, 33, 1, 115, 'spelling', 9, 1, '2026-04-19 21:31:45', 4, 1, '2026-04-09 21:31:45', '2026-04-09 21:31:45');
INSERT INTO `user_study_record` VALUES (130, 33, 2, 210, 'choice', 7, 3, '2026-04-16 21:31:45', 2, 1, '2026-04-09 21:31:45', '2026-04-09 21:31:45');
INSERT INTO `user_study_record` VALUES (131, 33, 1, 116, 'spelling', 10, 0, '2026-04-20 21:31:45', 5, 1, '2026-04-08 21:31:45', '2026-04-08 21:31:45');
INSERT INTO `user_study_record` VALUES (132, 33, 2, 211, 'choice', 8, 2, '2026-04-18 21:31:45', 3, 1, '2026-04-08 21:31:45', '2026-04-08 21:31:45');
INSERT INTO `user_study_record` VALUES (133, 33, 1, 117, 'choice', 9, 1, '2026-04-19 21:31:45', 4, 1, '2026-04-07 21:31:45', '2026-04-07 21:31:45');
INSERT INTO `user_study_record` VALUES (134, 33, 1, 118, 'spelling', 7, 3, '2026-04-16 21:31:45', 1, 1, '2026-04-07 21:31:45', '2026-04-07 21:31:45');
INSERT INTO `user_study_record` VALUES (135, 33, 2, 212, 'spelling', 8, 2, '2026-04-17 21:31:45', 3, 1, '2026-04-07 21:31:45', '2026-04-07 21:31:45');
INSERT INTO `user_study_record` VALUES (136, 33, 1, 119, 'choice', 6, 4, '2026-04-16 21:31:45', 2, 1, '2026-04-06 21:31:45', '2026-04-06 21:31:45');
INSERT INTO `user_study_record` VALUES (137, 33, 2, 213, 'spelling', 9, 1, '2026-04-18 21:31:45', 4, 1, '2026-04-06 21:31:45', '2026-04-06 21:31:45');
INSERT INTO `user_study_record` VALUES (138, 33, 1, 120, 'spelling', 8, 2, '2026-04-19 21:31:45', 3, 1, '2026-04-05 21:31:45', '2026-04-05 21:31:45');
INSERT INTO `user_study_record` VALUES (139, 33, 1, 121, 'choice', 10, 0, '2026-04-20 21:31:45', 5, 1, '2026-04-05 21:31:45', '2026-04-05 21:31:45');
INSERT INTO `user_study_record` VALUES (140, 33, 2, 214, 'choice', 7, 3, '2026-04-16 21:31:45', 1, 1, '2026-04-04 21:31:45', '2026-04-04 21:31:45');
INSERT INTO `user_study_record` VALUES (141, 33, 1, 122, 'spelling', 9, 1, '2026-04-18 21:31:45', 3, 1, '2026-04-04 21:31:45', '2026-04-04 21:31:45');
INSERT INTO `user_study_record` VALUES (142, 33, 1, 123, 'choice', 8, 2, '2026-04-19 21:31:45', 4, 1, '2026-04-03 21:31:45', '2026-04-03 21:31:45');
INSERT INTO `user_study_record` VALUES (143, 33, 2, 215, 'spelling', 6, 4, '2026-04-16 21:31:45', 2, 1, '2026-04-03 21:31:45', '2026-04-03 21:31:45');
INSERT INTO `user_study_record` VALUES (144, 33, 1, 124, 'spelling', 9, 1, '2026-04-17 21:31:45', 3, 1, '2026-04-02 21:31:45', '2026-04-02 21:31:45');
INSERT INTO `user_study_record` VALUES (145, 33, 2, 216, 'choice', 7, 3, '2026-04-18 21:31:45', 2, 1, '2026-04-01 21:31:45', '2026-04-01 21:31:45');
INSERT INTO `user_study_record` VALUES (146, 33, 1, 125, 'spelling', 8, 2, '2026-04-19 21:31:45', 3, 1, '2026-03-31 21:31:45', '2026-03-31 21:31:45');
INSERT INTO `user_study_record` VALUES (147, 33, 2, 217, 'choice', 9, 1, '2026-04-20 21:31:45', 4, 1, '2026-03-29 21:31:45', '2026-03-29 21:31:45');
INSERT INTO `user_study_record` VALUES (148, 33, 1, 126, 'spelling', 6, 4, '2026-04-16 21:31:45', 1, 1, '2026-03-28 21:31:45', '2026-03-28 21:31:45');
INSERT INTO `user_study_record` VALUES (149, 33, 2, 218, 'choice', 8, 2, '2026-04-18 21:31:45', 3, 1, '2026-03-26 21:31:45', '2026-03-26 21:31:45');
INSERT INTO `user_study_record` VALUES (150, 33, 1, 127, 'spelling', 10, 0, '2026-04-19 21:31:45', 5, 1, '2026-03-25 21:31:45', '2026-03-25 21:31:45');
INSERT INTO `user_study_record` VALUES (151, 33, 2, 219, 'choice', 7, 3, '2026-04-16 21:31:45', 2, 1, '2026-03-23 21:31:45', '2026-03-23 21:31:45');
INSERT INTO `user_study_record` VALUES (152, 33, 1, 128, 'spelling', 9, 1, '2026-04-17 21:31:45', 3, 1, '2026-03-22 21:31:45', '2026-03-22 21:31:45');
INSERT INTO `user_study_record` VALUES (153, 33, 2, 220, 'choice', 8, 2, '2026-04-18 21:31:45', 4, 1, '2026-03-20 21:31:45', '2026-03-20 21:31:45');
INSERT INTO `user_study_record` VALUES (154, 33, 1, 129, 'spelling', 6, 4, '2026-04-16 21:31:45', 1, 1, '2026-03-19 21:31:45', '2026-03-19 21:31:45');
INSERT INTO `user_study_record` VALUES (155, 33, 2, 221, 'choice', 9, 1, '2026-04-19 21:31:45', 3, 1, '2026-03-18 21:31:45', '2026-03-18 21:31:45');
INSERT INTO `user_study_record` VALUES (156, 33, 1, 130, 'spelling', 7, 3, '2026-04-18 21:31:45', 2, 1, '2026-03-17 21:31:45', '2026-03-17 21:31:45');
INSERT INTO `user_study_record` VALUES (157, 35, 3, 7, 'EN_TO_CN', 1, 0, '2026-04-23 19:22:10', 1, 1, '2026-04-17 19:57:05', '2026-04-17 19:57:05');
INSERT INTO `user_study_record` VALUES (158, 35, 3, 8, 'CN_TO_EN', 1, 0, '2026-04-23 19:22:15', 1, 1, '2026-04-17 19:57:05', '2026-04-17 19:57:05');
INSERT INTO `user_study_record` VALUES (159, 35, 3, 9, 'LISTEN', 1, 0, '2026-04-23 19:22:34', 1, 1, '2026-04-17 19:57:05', '2026-04-17 19:57:05');
INSERT INTO `user_study_record` VALUES (160, 35, 12, 115, 'CN_TO_EN', 0, 1, '2026-04-18 21:34:53', 1, 1, '2026-04-17 21:14:45', '2026-04-17 21:14:45');
INSERT INTO `user_study_record` VALUES (161, 35, 12, 116, 'CN_TO_EN', 1, 0, '2026-04-20 01:02:57', 1, 1, '2026-04-17 21:14:45', '2026-04-17 21:14:45');
INSERT INTO `user_study_record` VALUES (162, 35, 12, 117, 'CN_TO_EN', 0, 1, '2026-04-20 01:03:01', 1, 1, '2026-04-17 21:14:45', '2026-04-17 21:14:45');
INSERT INTO `user_study_record` VALUES (163, 35, 12, 118, 'EN_TO_CN', 1, 0, '2026-04-22 14:56:25', 1, 1, '2026-04-17 21:14:45', '2026-04-17 21:14:45');
INSERT INTO `user_study_record` VALUES (164, 35, 12, 119, 'EN_TO_CN', 1, 0, '2026-04-22 14:56:32', 1, 1, '2026-04-17 21:14:45', '2026-04-17 21:14:45');
INSERT INTO `user_study_record` VALUES (165, 36, 12, 115, 'EN_TO_CN', 0, 0, '2026-04-18 22:54:30', 0, 1, '2026-04-18 22:54:30', '2026-04-18 22:54:30');
INSERT INTO `user_study_record` VALUES (166, 36, 12, 116, 'EN_TO_CN', 0, 0, '2026-04-18 22:54:30', 0, 1, '2026-04-18 22:54:30', '2026-04-18 22:54:30');
INSERT INTO `user_study_record` VALUES (167, 36, 12, 117, 'EN_TO_CN', 0, 0, '2026-04-18 22:54:30', 0, 1, '2026-04-18 22:54:30', '2026-04-18 22:54:30');
INSERT INTO `user_study_record` VALUES (168, 36, 12, 118, 'EN_TO_CN', 0, 0, '2026-04-18 22:54:30', 0, 1, '2026-04-18 22:54:30', '2026-04-18 22:54:30');
INSERT INTO `user_study_record` VALUES (169, 36, 12, 119, 'EN_TO_CN', 0, 0, '2026-04-18 22:54:30', 0, 1, '2026-04-18 22:54:30', '2026-04-18 22:54:30');
INSERT INTO `user_study_record` VALUES (170, 35, 13, 120, 'EN_TO_CN', 0, 1, '2026-04-20 00:08:39', 1, 1, '2026-04-18 23:30:04', '2026-04-18 23:30:04');
INSERT INTO `user_study_record` VALUES (171, 35, 13, 121, 'EN_TO_CN', 0, 1, '2026-04-20 00:08:43', 1, 1, '2026-04-18 23:30:04', '2026-04-18 23:30:04');
INSERT INTO `user_study_record` VALUES (172, 35, 2, 4, 'EN_TO_CN', 0, 0, '2026-04-18 23:30:36', 0, 1, '2026-04-18 23:30:36', '2026-04-18 23:30:36');
INSERT INTO `user_study_record` VALUES (173, 35, 2, 5, 'EN_TO_CN', 0, 0, '2026-04-18 23:30:36', 0, 1, '2026-04-18 23:30:36', '2026-04-18 23:30:36');
INSERT INTO `user_study_record` VALUES (174, 35, 2, 6, 'EN_TO_CN', 0, 0, '2026-04-18 23:30:36', 0, 1, '2026-04-18 23:30:36', '2026-04-18 23:30:36');
INSERT INTO `user_study_record` VALUES (175, 35, 14, 122, 'EN_TO_CN', 0, 0, '2026-04-18 23:30:48', 0, 1, '2026-04-18 23:30:48', '2026-04-18 23:30:48');
INSERT INTO `user_study_record` VALUES (176, 35, 14, 123, 'EN_TO_CN', 0, 0, '2026-04-18 23:30:48', 0, 1, '2026-04-18 23:30:48', '2026-04-18 23:30:48');
INSERT INTO `user_study_record` VALUES (177, 35, 13, 124, 'CN_TO_EN', 1, 0, '2026-04-20 00:08:48', 1, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (178, 35, 13, 125, 'LISTEN', 1, 0, '2026-04-20 00:08:57', 1, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (179, 35, 13, 126, 'EN_TO_CN', 0, 1, '2026-04-20 01:03:12', 1, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (180, 35, 13, 127, 'CN_TO_EN', 1, 0, '2026-04-20 01:03:18', 1, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (181, 35, 13, 128, 'LISTEN', 0, 1, '2026-04-20 01:03:22', 1, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (182, 35, 13, 129, 'SPELL', 0, 1, '2026-04-20 01:03:30', 1, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (183, 35, 13, 130, 'EN_TO_CN', 1, 0, '2026-04-21 18:22:29', 1, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (184, 35, 13, 131, 'EN_TO_CN', 1, 0, '2026-04-21 18:22:41', 1, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (185, 35, 13, 132, 'EN_TO_CN', 0, 1, '2026-04-21 18:22:48', 1, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (186, 35, 13, 133, 'EN_TO_CN', 0, 0, '2026-04-19 00:08:33', 0, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (187, 35, 13, 134, 'EN_TO_CN', 0, 0, '2026-04-19 00:08:33', 0, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (188, 35, 13, 135, 'EN_TO_CN', 0, 0, '2026-04-19 00:08:33', 0, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (189, 35, 13, 136, 'EN_TO_CN', 0, 0, '2026-04-19 00:08:33', 0, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (190, 35, 13, 137, 'EN_TO_CN', 0, 0, '2026-04-19 00:08:33', 0, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (191, 35, 13, 138, 'EN_TO_CN', 0, 0, '2026-04-19 00:08:33', 0, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (192, 35, 13, 139, 'EN_TO_CN', 0, 0, '2026-04-19 00:08:33', 0, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (193, 35, 13, 140, 'EN_TO_CN', 0, 0, '2026-04-19 00:08:33', 0, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (194, 35, 13, 141, 'EN_TO_CN', 0, 0, '2026-04-19 00:08:33', 0, 1, '2026-04-19 00:08:33', '2026-04-19 00:08:33');
INSERT INTO `user_study_record` VALUES (195, 35, 13, 142, 'CN_TO_EN', 0, 0, '2026-04-19 00:08:45', 0, 1, '2026-04-19 00:08:45', '2026-04-19 00:08:45');
INSERT INTO `user_study_record` VALUES (196, 35, 13, 143, 'CN_TO_EN', 0, 0, '2026-04-19 00:08:45', 0, 1, '2026-04-19 00:08:45', '2026-04-19 00:08:45');
INSERT INTO `user_study_record` VALUES (197, 35, 13, 144, 'LISTEN', 0, 0, '2026-04-19 00:08:52', 0, 1, '2026-04-19 00:08:52', '2026-04-19 00:08:52');
INSERT INTO `user_study_record` VALUES (198, 35, 13, 145, 'CN_TO_EN', 1, 0, '2026-04-22 21:17:34', 1, 1, '2026-04-19 00:09:18', '2026-04-19 00:09:18');
INSERT INTO `user_study_record` VALUES (199, 35, 13, 146, 'CN_TO_EN', 1, 0, '2026-04-22 21:17:32', 1, 1, '2026-04-19 01:03:15', '2026-04-19 01:03:15');
INSERT INTO `user_study_record` VALUES (200, 35, 13, 147, 'CN_TO_EN', 1, 0, '2026-04-22 21:17:26', 1, 1, '2026-04-19 01:03:20', '2026-04-19 01:03:20');
INSERT INTO `user_study_record` VALUES (201, 35, 13, 148, 'CN_TO_EN', 1, 0, '2026-04-22 21:17:19', 1, 1, '2026-04-19 01:03:24', '2026-04-19 01:03:24');
INSERT INTO `user_study_record` VALUES (202, 35, 13, 149, 'CN_TO_EN', 1, 0, '2026-04-22 21:17:12', 1, 1, '2026-04-19 01:04:44', '2026-04-19 01:04:44');
INSERT INTO `user_study_record` VALUES (203, 35, 1, 1, 'EN_TO_CN', 0, 0, '2026-04-20 15:20:10', 0, 1, '2026-04-20 15:20:10', '2026-04-20 15:20:10');
INSERT INTO `user_study_record` VALUES (204, 35, 1, 2, 'EN_TO_CN', 1, 0, '2026-04-23 21:37:01', 1, 1, '2026-04-20 15:20:10', '2026-04-20 15:20:10');
INSERT INTO `user_study_record` VALUES (205, 35, 1, 3, 'EN_TO_CN', 0, 0, '2026-04-20 15:20:10', 0, 1, '2026-04-20 15:20:10', '2026-04-20 15:20:10');
INSERT INTO `user_study_record` VALUES (206, 35, 15, 307, 'EN_TO_CN', 0, 0, '2026-04-20 21:17:17', 0, 1, '2026-04-20 21:17:17', '2026-04-20 21:17:17');
INSERT INTO `user_study_record` VALUES (207, 35, 15, 308, 'EN_TO_CN', 0, 0, '2026-04-20 21:17:17', 0, 1, '2026-04-20 21:17:17', '2026-04-20 21:17:17');
INSERT INTO `user_study_record` VALUES (208, 35, 15, 309, 'EN_TO_CN', 0, 0, '2026-04-20 21:17:17', 0, 1, '2026-04-20 21:17:17', '2026-04-20 21:17:17');
INSERT INTO `user_study_record` VALUES (209, 35, 15, 310, 'EN_TO_CN', 0, 0, '2026-04-20 21:17:17', 0, 1, '2026-04-20 21:17:17', '2026-04-20 21:17:17');
INSERT INTO `user_study_record` VALUES (210, 35, 15, 311, 'EN_TO_CN', 0, 0, '2026-04-20 21:17:17', 0, 1, '2026-04-20 21:17:17', '2026-04-20 21:17:17');
INSERT INTO `user_study_record` VALUES (211, 35, 1, 312, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (212, 35, 1, 313, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (213, 35, 1, 314, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (214, 35, 1, 315, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (215, 35, 1, 316, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (216, 35, 1, 317, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (217, 35, 1, 318, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (218, 35, 1, 319, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (219, 35, 1, 320, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (220, 35, 1, 321, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (221, 35, 1, 322, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (222, 35, 1, 323, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (223, 35, 1, 324, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (224, 35, 1, 325, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (225, 35, 1, 326, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (226, 35, 1, 327, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (227, 35, 1, 328, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (228, 35, 1, 329, 'EN_TO_CN', 0, 0, '2026-04-21 21:42:55', 0, 1, '2026-04-21 21:42:55', '2026-04-21 21:42:55');
INSERT INTO `user_study_record` VALUES (229, 35, 3, 565, 'EN_TO_CN', 1, 0, '2026-04-24 08:45:41', 1, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (230, 35, 3, 566, 'EN_TO_CN', 0, 1, '2026-04-24 08:45:47', 1, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (231, 35, 3, 567, 'CN_TO_EN', 0, 1, '2026-04-24 08:45:52', 1, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (232, 35, 3, 568, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (233, 35, 3, 569, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (234, 35, 3, 570, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (235, 35, 3, 571, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (236, 35, 3, 572, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (237, 35, 3, 573, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (238, 35, 3, 574, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (239, 35, 3, 575, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (240, 35, 3, 576, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (241, 35, 3, 577, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (242, 35, 3, 578, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (243, 35, 3, 579, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (244, 35, 3, 580, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (245, 35, 3, 581, 'EN_TO_CN', 0, 0, '2026-04-22 19:22:08', 0, 1, '2026-04-22 19:22:08', '2026-04-22 19:22:08');
INSERT INTO `user_study_record` VALUES (246, 35, 3, 582, 'CN_TO_EN', 0, 0, '2026-04-22 19:22:13', 0, 1, '2026-04-22 19:22:13', '2026-04-22 19:22:13');
INSERT INTO `user_study_record` VALUES (247, 35, 3, 583, 'LISTEN', 0, 0, '2026-04-22 19:22:18', 0, 1, '2026-04-22 19:22:18', '2026-04-22 19:22:18');
INSERT INTO `user_study_record` VALUES (248, 35, 3, 584, 'SPELL', 0, 0, '2026-04-22 19:22:36', 0, 1, '2026-04-22 19:22:36', '2026-04-22 19:22:36');
INSERT INTO `user_study_record` VALUES (249, 35, 3, 585, 'CN_TO_EN', 0, 0, '2026-04-23 08:45:49', 0, 1, '2026-04-23 08:45:49', '2026-04-23 08:45:49');
INSERT INTO `user_study_record` VALUES (250, 35, 3, 586, 'CN_TO_EN', 0, 0, '2026-04-23 08:45:49', 0, 1, '2026-04-23 08:45:49', '2026-04-23 08:45:49');
INSERT INTO `user_study_record` VALUES (251, 35, 3, 587, 'EN_TO_CN', 0, 1, '2026-04-24 08:46:49', 1, 1, '2026-04-23 08:45:54', '2026-04-23 08:45:54');
INSERT INTO `user_study_record` VALUES (252, 35, 3, 588, 'SPELL', 0, 0, '2026-04-23 12:05:42', 0, 1, '2026-04-23 12:05:42', '2026-04-23 12:05:42');
INSERT INTO `user_study_record` VALUES (253, 39, 3, 7, 'CN_TO_EN', 1, 0, '2026-04-24 13:33:45', 1, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (254, 39, 3, 8, 'EN_TO_CN', 0, 1, '2026-04-24 13:41:07', 1, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (255, 39, 3, 9, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (256, 39, 3, 565, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (257, 39, 3, 566, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (258, 39, 3, 567, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (259, 39, 3, 568, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (260, 39, 3, 569, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (261, 39, 3, 570, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (262, 39, 3, 571, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (263, 39, 3, 572, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (264, 39, 3, 573, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (265, 39, 3, 574, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (266, 39, 3, 575, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (267, 39, 3, 576, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (268, 39, 3, 577, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (269, 39, 3, 578, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (270, 39, 3, 579, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (271, 39, 3, 580, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (272, 39, 3, 581, 'EN_TO_CN', 0, 0, '2026-04-23 13:33:02', 0, 1, '2026-04-23 13:33:02', '2026-04-23 13:33:02');
INSERT INTO `user_study_record` VALUES (273, 39, 13, 120, 'EN_TO_CN', 0, 1, '2026-04-24 13:40:59', 1, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (274, 39, 13, 121, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (275, 39, 13, 124, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (276, 39, 13, 125, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (277, 39, 13, 126, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (278, 39, 13, 127, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (279, 39, 13, 128, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (280, 39, 13, 129, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (281, 39, 13, 130, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (282, 39, 13, 131, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (283, 39, 13, 132, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (284, 39, 13, 133, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (285, 39, 13, 134, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (286, 39, 13, 135, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (287, 39, 13, 136, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (288, 39, 13, 137, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (289, 39, 13, 138, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (290, 39, 13, 139, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (291, 39, 13, 140, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (292, 39, 13, 141, 'EN_TO_CN', 0, 0, '2026-04-23 13:40:57', 0, 1, '2026-04-23 13:40:57', '2026-04-23 13:40:57');
INSERT INTO `user_study_record` VALUES (293, 39, 3, 582, 'EN_TO_CN', 0, 0, '2026-04-23 13:41:06', 0, 1, '2026-04-23 13:41:06', '2026-04-23 13:41:06');
INSERT INTO `user_study_record` VALUES (294, 39, 3, 583, 'EN_TO_CN', 0, 0, '2026-04-23 14:07:31', 0, 1, '2026-04-23 14:07:31', '2026-04-23 14:07:31');
INSERT INTO `user_study_record` VALUES (295, 40, 3, 7, 'EN_TO_CN', 1, 0, '2026-04-25 18:07:04', 1, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (296, 40, 3, 8, 'EN_TO_CN', 0, 1, '2026-04-25 18:07:07', 1, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (297, 40, 3, 9, 'CN_TO_EN', 1, 0, '2026-04-25 18:07:12', 1, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (298, 40, 3, 565, 'CN_TO_EN', 0, 1, '2026-04-25 18:07:14', 1, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (299, 40, 3, 566, 'LISTEN', 1, 0, '2026-04-25 18:07:19', 1, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (300, 40, 3, 567, 'LISTEN', 1, 0, '2026-04-25 18:07:21', 1, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (301, 40, 3, 568, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (302, 40, 3, 569, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (303, 40, 3, 570, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (304, 40, 3, 571, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (305, 40, 3, 572, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (306, 40, 3, 573, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (307, 40, 3, 574, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (308, 40, 3, 575, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (309, 40, 3, 576, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (310, 40, 3, 577, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (311, 40, 3, 578, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (312, 40, 3, 579, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (313, 40, 3, 580, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (314, 40, 3, 581, 'EN_TO_CN', 0, 0, '2026-04-24 18:07:01', 0, 1, '2026-04-24 18:07:01', '2026-04-24 18:07:01');
INSERT INTO `user_study_record` VALUES (315, 40, 3, 582, 'CN_TO_EN', 0, 0, '2026-04-24 18:07:09', 0, 1, '2026-04-24 18:07:09', '2026-04-24 18:07:09');
INSERT INTO `user_study_record` VALUES (316, 40, 3, 583, 'CN_TO_EN', 0, 0, '2026-04-24 18:07:09', 0, 1, '2026-04-24 18:07:09', '2026-04-24 18:07:09');
INSERT INTO `user_study_record` VALUES (317, 40, 3, 584, 'LISTEN', 0, 0, '2026-04-24 18:07:16', 0, 1, '2026-04-24 18:07:16', '2026-04-24 18:07:16');
INSERT INTO `user_study_record` VALUES (318, 40, 3, 585, 'LISTEN', 0, 0, '2026-04-24 18:07:16', 0, 1, '2026-04-24 18:07:16', '2026-04-24 18:07:16');
INSERT INTO `user_study_record` VALUES (319, 40, 3, 586, 'SPELL', 0, 0, '2026-04-24 18:07:23', 0, 1, '2026-04-24 18:07:23', '2026-04-24 18:07:23');
INSERT INTO `user_study_record` VALUES (320, 40, 3, 587, 'SPELL', 0, 0, '2026-04-24 18:07:23', 0, 1, '2026-04-24 18:07:23', '2026-04-24 18:07:23');
INSERT INTO `user_study_record` VALUES (321, 42, 3, 7, 'EN_TO_CN', 1, 0, '2026-04-26 10:43:08', 1, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (322, 42, 3, 8, 'EN_TO_CN', 0, 1, '2026-04-26 10:43:11', 1, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (323, 42, 3, 9, 'CN_TO_EN', 1, 0, '2026-04-26 10:43:15', 1, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (324, 42, 3, 565, 'CN_TO_EN', 0, 1, '2026-04-26 10:43:18', 1, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (325, 42, 3, 566, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (326, 42, 3, 567, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (327, 42, 3, 568, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (328, 42, 3, 569, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (329, 42, 3, 570, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (330, 42, 3, 571, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (331, 42, 3, 572, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (332, 42, 3, 573, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:06', '2026-04-25 10:43:06');
INSERT INTO `user_study_record` VALUES (333, 42, 3, 574, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:07', '2026-04-25 10:43:07');
INSERT INTO `user_study_record` VALUES (334, 42, 3, 575, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:07', '2026-04-25 10:43:07');
INSERT INTO `user_study_record` VALUES (335, 42, 3, 576, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:07', '2026-04-25 10:43:07');
INSERT INTO `user_study_record` VALUES (336, 42, 3, 577, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:07', '2026-04-25 10:43:07');
INSERT INTO `user_study_record` VALUES (337, 42, 3, 578, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:07', '2026-04-25 10:43:07');
INSERT INTO `user_study_record` VALUES (338, 42, 3, 579, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:07', '2026-04-25 10:43:07');
INSERT INTO `user_study_record` VALUES (339, 42, 3, 580, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:07', '2026-04-25 10:43:07');
INSERT INTO `user_study_record` VALUES (340, 42, 3, 581, 'EN_TO_CN', 0, 0, '2026-04-25 10:43:06', 0, 1, '2026-04-25 10:43:07', '2026-04-25 10:43:07');
INSERT INTO `user_study_record` VALUES (341, 42, 3, 582, 'CN_TO_EN', 0, 0, '2026-04-25 10:43:14', 0, 1, '2026-04-25 10:43:14', '2026-04-25 10:43:14');
INSERT INTO `user_study_record` VALUES (342, 42, 3, 583, 'CN_TO_EN', 0, 0, '2026-04-25 10:43:14', 0, 1, '2026-04-25 10:43:14', '2026-04-25 10:43:14');
INSERT INTO `user_study_record` VALUES (343, 42, 3, 584, 'LISTEN', 0, 0, '2026-04-25 10:43:19', 0, 1, '2026-04-25 10:43:19', '2026-04-25 10:43:19');
INSERT INTO `user_study_record` VALUES (344, 42, 3, 585, 'LISTEN', 0, 0, '2026-04-25 10:43:19', 0, 1, '2026-04-25 10:43:19', '2026-04-25 10:43:19');
INSERT INTO `user_study_record` VALUES (345, 43, 3, 7, 'EN_TO_CN', 0, 1, '2026-04-26 10:53:05', 1, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (346, 43, 3, 8, 'EN_TO_CN', 0, 1, '2026-04-26 10:53:10', 1, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (347, 43, 3, 9, 'EN_TO_CN', 0, 1, '2026-04-26 10:53:16', 1, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (348, 43, 3, 565, 'EN_TO_CN', 1, 0, '2026-04-26 10:53:19', 1, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (349, 43, 3, 566, 'CN_TO_EN', 0, 1, '2026-04-26 10:53:25', 1, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (350, 43, 3, 567, 'LISTEN', 0, 1, '2026-04-26 10:53:30', 1, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (351, 43, 3, 568, 'SPELL', 0, 1, '2026-04-26 10:53:41', 1, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (352, 43, 3, 569, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (353, 43, 3, 570, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (354, 43, 3, 571, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (355, 43, 3, 572, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (356, 43, 3, 573, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (357, 43, 3, 574, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (358, 43, 3, 575, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (359, 43, 3, 576, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (360, 43, 3, 577, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (361, 43, 3, 578, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (362, 43, 3, 579, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (363, 43, 3, 580, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (364, 43, 3, 581, 'EN_TO_CN', 0, 0, '2026-04-25 10:52:54', 0, 1, '2026-04-25 10:52:54', '2026-04-25 10:52:54');
INSERT INTO `user_study_record` VALUES (365, 43, 3, 582, 'CN_TO_EN', 0, 0, '2026-04-25 10:53:20', 0, 1, '2026-04-25 10:53:20', '2026-04-25 10:53:20');
INSERT INTO `user_study_record` VALUES (366, 43, 3, 583, 'CN_TO_EN', 0, 0, '2026-04-25 10:53:20', 0, 1, '2026-04-25 10:53:20', '2026-04-25 10:53:20');
INSERT INTO `user_study_record` VALUES (367, 43, 3, 584, 'CN_TO_EN', 0, 0, '2026-04-25 10:53:20', 0, 1, '2026-04-25 10:53:20', '2026-04-25 10:53:20');
INSERT INTO `user_study_record` VALUES (368, 43, 3, 585, 'CN_TO_EN', 0, 0, '2026-04-25 10:53:20', 0, 1, '2026-04-25 10:53:20', '2026-04-25 10:53:20');
INSERT INTO `user_study_record` VALUES (369, 43, 3, 586, 'EN_TO_CN', 0, 1, '2026-04-26 10:54:00', 1, 1, '2026-04-25 10:53:28', '2026-04-25 10:53:28');
INSERT INTO `user_study_record` VALUES (370, 43, 3, 587, 'EN_TO_CN', 1, 0, '2026-04-26 10:53:57', 1, 1, '2026-04-25 10:53:32', '2026-04-25 10:53:32');
INSERT INTO `user_study_record` VALUES (371, 44, 13, 120, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (372, 44, 13, 121, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (373, 44, 13, 124, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (374, 44, 13, 125, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (375, 44, 13, 126, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (376, 44, 13, 127, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (377, 44, 13, 128, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (378, 44, 13, 129, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (379, 44, 13, 130, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (380, 44, 13, 131, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (381, 44, 13, 132, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (382, 44, 13, 133, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (383, 44, 13, 134, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (384, 44, 13, 135, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (385, 44, 13, 136, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (386, 44, 13, 137, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (387, 44, 13, 138, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (388, 44, 13, 139, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (389, 44, 13, 140, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (390, 44, 13, 141, 'EN_TO_CN', 0, 0, '2026-04-25 10:56:56', 0, 1, '2026-04-25 10:56:56', '2026-04-25 10:56:56');
INSERT INTO `user_study_record` VALUES (391, 41, 13, 120, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (392, 41, 13, 121, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (393, 41, 13, 124, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (394, 41, 13, 125, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (395, 41, 13, 126, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (396, 41, 13, 127, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (397, 41, 13, 128, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (398, 41, 13, 129, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (399, 41, 13, 130, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (400, 41, 13, 131, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (401, 41, 13, 132, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (402, 41, 13, 133, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (403, 41, 13, 134, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (404, 41, 13, 135, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (405, 41, 13, 136, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (406, 41, 13, 137, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (407, 41, 13, 138, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (408, 41, 13, 139, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (409, 41, 13, 140, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (410, 41, 13, 141, 'EN_TO_CN', 0, 0, '2026-04-25 11:04:34', 0, 1, '2026-04-25 11:04:34', '2026-04-25 11:04:34');
INSERT INTO `user_study_record` VALUES (411, 43, 18, 798, 'EN_TO_CN', 0, 0, '2026-04-25 11:05:23', 0, 1, '2026-04-25 11:05:23', '2026-04-25 11:05:23');
INSERT INTO `user_study_record` VALUES (412, 43, 18, 799, 'EN_TO_CN', 0, 0, '2026-04-25 11:05:23', 0, 1, '2026-04-25 11:05:23', '2026-04-25 11:05:23');
INSERT INTO `user_study_record` VALUES (413, 43, 18, 800, 'EN_TO_CN', 0, 0, '2026-04-25 11:05:23', 0, 1, '2026-04-25 11:05:23', '2026-04-25 11:05:23');
INSERT INTO `user_study_record` VALUES (414, 43, 18, 801, 'EN_TO_CN', 0, 0, '2026-04-25 11:05:23', 0, 1, '2026-04-25 11:05:23', '2026-04-25 11:05:23');
INSERT INTO `user_study_record` VALUES (415, 43, 18, 802, 'EN_TO_CN', 0, 0, '2026-04-25 11:05:23', 0, 1, '2026-04-25 11:05:23', '2026-04-25 11:05:23');
INSERT INTO `user_study_record` VALUES (416, 46, 3, 7, 'EN_TO_CN', 0, 1, '2026-04-26 11:54:18', 1, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (417, 46, 3, 8, 'EN_TO_CN', 1, 0, '2026-04-26 11:54:23', 1, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (418, 46, 3, 9, 'CN_TO_EN', 0, 1, '2026-04-26 11:54:25', 1, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (419, 46, 3, 565, 'CN_TO_EN', 1, 0, '2026-04-26 11:54:28', 1, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (420, 46, 3, 566, 'LISTEN', 1, 0, '2026-04-26 11:54:31', 1, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (421, 46, 3, 567, 'LISTEN', 0, 1, '2026-04-26 11:54:36', 1, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (422, 46, 3, 568, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (423, 46, 3, 569, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (424, 46, 3, 570, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (425, 46, 3, 571, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (426, 46, 3, 572, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (427, 46, 3, 573, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (428, 46, 3, 574, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (429, 46, 3, 575, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (430, 46, 3, 576, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (431, 46, 3, 577, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (432, 46, 3, 578, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (433, 46, 3, 579, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (434, 46, 3, 580, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (435, 46, 3, 581, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:10', 0, 1, '2026-04-25 11:54:10', '2026-04-25 11:54:10');
INSERT INTO `user_study_record` VALUES (436, 46, 2, 4, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:12', 0, 1, '2026-04-25 11:54:12', '2026-04-25 11:54:12');
INSERT INTO `user_study_record` VALUES (437, 46, 2, 5, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:12', 0, 1, '2026-04-25 11:54:12', '2026-04-25 11:54:12');
INSERT INTO `user_study_record` VALUES (438, 46, 2, 6, 'EN_TO_CN', 0, 0, '2026-04-25 11:54:12', 0, 1, '2026-04-25 11:54:12', '2026-04-25 11:54:12');
INSERT INTO `user_study_record` VALUES (439, 46, 3, 582, 'CN_TO_EN', 0, 0, '2026-04-25 11:54:24', 0, 1, '2026-04-25 11:54:24', '2026-04-25 11:54:24');
INSERT INTO `user_study_record` VALUES (440, 46, 3, 583, 'CN_TO_EN', 0, 0, '2026-04-25 11:54:24', 0, 1, '2026-04-25 11:54:24', '2026-04-25 11:54:24');
INSERT INTO `user_study_record` VALUES (441, 46, 3, 584, 'LISTEN', 0, 0, '2026-04-25 11:54:29', 0, 1, '2026-04-25 11:54:29', '2026-04-25 11:54:29');
INSERT INTO `user_study_record` VALUES (442, 46, 3, 585, 'LISTEN', 0, 0, '2026-04-25 11:54:29', 0, 1, '2026-04-25 11:54:29', '2026-04-25 11:54:29');
INSERT INTO `user_study_record` VALUES (443, 46, 3, 586, 'SPELL', 0, 0, '2026-04-25 11:54:37', 0, 1, '2026-04-25 11:54:37', '2026-04-25 11:54:37');
INSERT INTO `user_study_record` VALUES (444, 46, 3, 587, 'SPELL', 0, 0, '2026-04-25 11:54:37', 0, 1, '2026-04-25 11:54:37', '2026-04-25 11:54:37');
INSERT INTO `user_study_record` VALUES (445, 46, 1, 2, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (446, 46, 1, 3, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (447, 46, 1, 312, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (448, 46, 1, 313, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (449, 46, 1, 314, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (450, 46, 1, 315, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (451, 46, 1, 316, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (452, 46, 1, 317, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (453, 46, 1, 318, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (454, 46, 1, 319, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (455, 46, 1, 320, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (456, 46, 1, 321, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (457, 46, 1, 322, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (458, 46, 1, 323, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (459, 46, 1, 324, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (460, 46, 1, 325, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (461, 46, 1, 326, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (462, 46, 1, 327, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (463, 46, 1, 328, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (464, 46, 1, 329, 'EN_TO_CN', 0, 0, '2026-04-25 11:55:35', 0, 1, '2026-04-25 11:55:35', '2026-04-25 11:55:35');
INSERT INTO `user_study_record` VALUES (465, 35, 23, 818, 'EN_TO_CN', 1, 0, '2026-04-28 22:46:16', 1, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (466, 35, 23, 819, 'CN_TO_EN', 0, 1, '2026-04-28 22:46:20', 1, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (467, 35, 23, 820, 'LISTEN', 0, 1, '2026-04-28 22:46:28', 1, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (468, 35, 23, 821, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (469, 35, 23, 822, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (470, 35, 23, 823, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (471, 35, 23, 824, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (472, 35, 23, 825, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (473, 35, 23, 826, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (474, 35, 23, 827, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (475, 35, 23, 828, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (476, 35, 23, 829, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (477, 35, 23, 830, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (478, 35, 23, 831, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (479, 35, 23, 832, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (480, 35, 23, 833, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (481, 35, 23, 834, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (482, 35, 23, 835, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (483, 35, 23, 836, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (484, 35, 23, 837, 'EN_TO_CN', 0, 0, '2026-04-27 19:32:02', 0, 1, '2026-04-27 19:32:02', '2026-04-27 19:32:02');
INSERT INTO `user_study_record` VALUES (485, 35, 23, 838, 'CN_TO_EN', 0, 0, '2026-04-27 22:46:17', 0, 1, '2026-04-27 22:46:17', '2026-04-27 22:46:17');
INSERT INTO `user_study_record` VALUES (486, 35, 23, 839, 'LISTEN', 0, 0, '2026-04-27 22:46:22', 0, 1, '2026-04-27 22:46:22', '2026-04-27 22:46:22');
INSERT INTO `user_study_record` VALUES (487, 35, 23, 840, 'SPELL', 0, 0, '2026-04-27 22:46:33', 0, 1, '2026-04-27 22:46:33', '2026-04-27 22:46:33');
INSERT INTO `user_study_record` VALUES (488, 35, 24, 977, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:44', '2026-04-27 22:48:44');
INSERT INTO `user_study_record` VALUES (489, 35, 24, 978, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:44', '2026-04-27 22:48:44');
INSERT INTO `user_study_record` VALUES (490, 35, 24, 979, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:44', '2026-04-27 22:48:44');
INSERT INTO `user_study_record` VALUES (491, 35, 24, 980, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:44', '2026-04-27 22:48:44');
INSERT INTO `user_study_record` VALUES (492, 35, 24, 981, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:44', '2026-04-27 22:48:44');
INSERT INTO `user_study_record` VALUES (493, 35, 24, 982, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:44', '2026-04-27 22:48:44');
INSERT INTO `user_study_record` VALUES (494, 35, 24, 983, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:44', '2026-04-27 22:48:44');
INSERT INTO `user_study_record` VALUES (495, 35, 24, 984, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:44', '2026-04-27 22:48:44');
INSERT INTO `user_study_record` VALUES (496, 35, 24, 985, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (497, 35, 24, 986, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (498, 35, 24, 987, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (499, 35, 24, 988, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (500, 35, 24, 989, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (501, 35, 24, 990, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (502, 35, 24, 991, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (503, 35, 24, 992, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (504, 35, 24, 993, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (505, 35, 24, 994, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (506, 35, 24, 995, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');
INSERT INTO `user_study_record` VALUES (507, 35, 24, 996, 'EN_TO_CN', 0, 0, '2026-04-27 22:48:44', 0, 1, '2026-04-27 22:48:45', '2026-04-27 22:48:45');

-- ----------------------------
-- Table structure for word
-- ----------------------------
DROP TABLE IF EXISTS `word`;
CREATE TABLE `word`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `word_bank_id` bigint NOT NULL COMMENT '词库ID（逻辑外键，关联word_bank.id）',
  `english` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '英文单词',
  `language` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'EN' COMMENT '单词语种：EN/JA/KO',
  `phonetic` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '音标',
  `chinese` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '中文释义',
  `example` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '例句',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-禁用/删除',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_word_bank_language_english_status`(`word_bank_id` ASC, `language` ASC, `english` ASC, `status` ASC) USING BTREE,
  INDEX `idx_word_bank_id`(`word_bank_id` ASC) USING BTREE,
  INDEX `idx_english`(`english` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_language`(`language` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1846 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '单词表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of word
-- ----------------------------
INSERT INTO `word` VALUES (1, 1, 'ability', 'EN', '/əˈbɪləti/', '能力；才能', 'She has the ability to solve difficult problems.', 0, '2026-04-14 13:05:41', '2026-04-21 20:25:35');
INSERT INTO `word` VALUES (2, 1, 'achieve', 'EN', '/əˈtʃiːv/', '实现；达到', 'You can achieve your goal through practice.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (3, 1, 'approach', 'EN', '/əˈprəʊtʃ/', '方法；接近', 'We need a better approach to learning new words.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (4, 2, 'accelerate', 'EN', '/əkˈseləreɪt/', '加速；促进', 'The new policy will accelerate economic growth.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (5, 2, 'conservative', 'EN', '/kənˈsɜːvətɪv/', '保守的；守旧的', 'He holds a conservative view on education.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (6, 2, 'derive', 'EN', '/dɪˈraɪv/', '获得；起源于', 'Many English words derive from Latin.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (7, 3, 'abolish', 'EN', '/əˈbɒlɪʃ/', '废除；取消', 'The law was abolished many years ago.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (8, 3, 'compile', 'EN', '/kəmˈpaɪl/', '编写；汇编', 'She compiled a list of important expressions.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (9, 3, 'retain', 'EN', '/rɪˈteɪn/', '保持；保留', 'Regular review helps retain vocabulary.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (10, 4, 'algorithm', 'EN', '/ˈælɡərɪðəm/', '算法', 'This algorithm sorts the data efficiently.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (11, 4, 'database', 'EN', '/ˈdeɪtəbeɪs/', '数据库', 'The system stores records in a database.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (12, 5, 'grocery', 'EN', '/ˈɡrəʊsəri/', '食品杂货店', 'I bought fruit from the grocery store.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (13, 5, 'schedule', 'EN', '/ˈʃedjuːl/', '日程；安排', 'My study schedule starts at seven every evening.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (14, 6, 'contract', 'EN', '/ˈkɒntrækt/', '合同', 'The company signed a new contract yesterday.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (15, 6, 'negotiate', 'EN', '/nɪˈɡəʊʃieɪt/', '谈判；协商', 'They negotiated the price for two hours.', 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word` VALUES (49, 9, 'configstaff', 'EN', NULL, '配置人员', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (50, 9, 'achieve', 'EN', NULL, '实现，达到', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (51, 9, 'notification', 'EN', NULL, '通知，通告', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (52, 9, 'enable', 'EN', NULL, '启用，使能够', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (53, 9, 'display', 'EN', NULL, '显示，展示', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (54, 9, 'transition', 'EN', NULL, '过渡，转变', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (55, 9, 'instant', 'EN', NULL, '立即的，瞬间', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (56, 9, 'continuous', 'EN', NULL, '连续的，持续的', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (57, 9, 'coating', 'EN', NULL, '涂层，覆盖层', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (58, 9, 'coat', 'EN', NULL, '外套；涂层', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (59, 9, 'paleness', 'EN', NULL, '苍白，无血色', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (60, 9, 'bury', 'EN', NULL, '埋葬，掩埋', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (61, 9, 'pure', 'EN', NULL, '纯净的，纯粹的', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (62, 9, 'wipe', 'EN', NULL, '擦，擦拭', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (63, 9, 'profile', 'EN', NULL, '轮廓；简介；用户资料', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (64, 9, 'peacefully', 'EN', NULL, '和平地，平静地', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (65, 9, 'sorrowful', 'EN', NULL, '悲伤的，悲痛的', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (66, 9, 'hate', 'EN', NULL, '憎恨，讨厌', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (67, 9, 'just', 'EN', NULL, '刚刚；仅仅；公正地', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (68, 9, 'rather', 'EN', NULL, '宁愿；相当', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (69, 9, 'wonder', 'EN', NULL, '想知道；奇迹', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (70, 9, 'almost', 'EN', NULL, '几乎，差不多', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (71, 9, 'another', 'EN', NULL, '另一个', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (72, 9, 'trek', 'EN', NULL, '长途跋涉，艰苦跋涉', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (73, 9, 'level', 'EN', NULL, '水平；等级；楼层', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (74, 9, 'straight', 'EN', NULL, '直的；直接地', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (75, 9, 'probably', 'EN', NULL, '很可能，大概', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (76, 9, 'figure', 'EN', NULL, '数字；人物；认为', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (77, 9, 'vacation', 'EN', NULL, '假期，休假', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (78, 9, 'stroll', 'EN', NULL, '散步，闲逛', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (79, 9, 'leisurely', 'EN', NULL, '悠闲地，从容地', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (80, 9, 'unfazed', 'EN', NULL, '不慌不忙的，镇定的', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (81, 9, 'moment', 'EN', NULL, '时刻，瞬间', NULL, 1, '2026-04-14 18:10:15', '2026-04-14 18:10:15');
INSERT INTO `word` VALUES (82, 8, 'configstaff', 'EN', NULL, '配置人员', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (83, 8, 'achieve', 'EN', NULL, '实现，达到', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (84, 8, 'notification', 'EN', NULL, '通知，通告', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (85, 8, 'enable', 'EN', NULL, '启用，使能够', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (86, 8, 'display', 'EN', NULL, '显示，展示', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (87, 8, 'transition', 'EN', NULL, '过渡，转变', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (88, 8, 'instant', 'EN', NULL, '立即的，瞬间', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (89, 8, 'continuous', 'EN', NULL, '连续的，持续的', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (90, 8, 'coating', 'EN', NULL, '涂层，覆盖层', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (91, 8, 'coat', 'EN', NULL, '外套；涂层', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (92, 8, 'paleness', 'EN', NULL, '苍白，无血色', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (93, 8, 'bury', 'EN', NULL, '埋葬，掩埋', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (94, 8, 'pure', 'EN', NULL, '纯净的，纯粹的', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (95, 8, 'wipe', 'EN', NULL, '擦，擦拭', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (96, 8, 'profile', 'EN', NULL, '轮廓；简介；用户资料', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (97, 8, 'peacefully', 'EN', NULL, '和平地，平静地', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (98, 8, 'sorrowful', 'EN', NULL, '悲伤的，悲痛的', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (99, 8, 'hate', 'EN', NULL, '憎恨，讨厌', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (100, 8, 'just', 'EN', NULL, '刚刚；仅仅；公正地', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (101, 8, 'rather', 'EN', NULL, '宁愿；相当', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (102, 8, 'wonder', 'EN', NULL, '想知道；奇迹', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (103, 8, 'almost', 'EN', NULL, '几乎，差不多', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (104, 8, 'another', 'EN', NULL, '另一个', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (105, 8, 'trek', 'EN', NULL, '长途跋涉，艰苦跋涉', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (106, 8, 'level', 'EN', NULL, '水平；等级；楼层', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (107, 8, 'straight', 'EN', NULL, '直的；直接地', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (108, 8, 'probably', 'EN', NULL, '很可能，大概', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (109, 8, 'figure', 'EN', NULL, '数字；人物；认为', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (110, 8, 'vacation', 'EN', NULL, '假期，休假', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (111, 8, 'stroll', 'EN', NULL, '散步，闲逛', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (112, 8, 'leisurely', 'EN', NULL, '悠闲地，从容地', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (113, 8, 'unfazed', 'EN', NULL, '不慌不忙的，镇定的', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (114, 8, 'moment', 'EN', NULL, '时刻，瞬间', NULL, 1, '2026-04-14 18:13:04', '2026-04-14 18:13:04');
INSERT INTO `word` VALUES (115, 12, 'hello', 'EN', '/həˈləʊ/', '你好', 'Hello, nice to meet you!', 1, '2026-04-17 20:51:39', '2026-04-17 20:51:39');
INSERT INTO `word` VALUES (116, 12, 'world', 'EN', '/wɜːld/', '世界', 'Welcome to the world!', 1, '2026-04-17 20:51:39', '2026-04-17 20:51:39');
INSERT INTO `word` VALUES (117, 12, 'computer', 'EN', '/kəmˈpjuːtər/', '计算机', 'I use computer every day.', 1, '2026-04-17 20:51:39', '2026-04-17 20:51:39');
INSERT INTO `word` VALUES (118, 12, 'english', 'EN', '/ˈɪŋɡlɪʃ/', '英语', 'I am learning English.', 1, '2026-04-17 20:51:39', '2026-04-17 20:51:39');
INSERT INTO `word` VALUES (119, 12, 'study', 'EN', '/ˈstʌdi/', '学习', 'Study makes me happy.', 1, '2026-04-17 20:51:39', '2026-04-17 20:51:39');
INSERT INTO `word` VALUES (120, 13, 'こんにちは', 'JA', NULL, '你好', 'こんにちは、はじめまして。', 1, '2026-04-18 23:28:09', '2026-04-18 23:28:09');
INSERT INTO `word` VALUES (121, 13, 'ありがとう', 'JA', NULL, '谢谢', '手伝ってくれて、ありがとう。', 1, '2026-04-18 23:28:09', '2026-04-18 23:28:09');
INSERT INTO `word` VALUES (122, 14, '사랑', 'KO', NULL, '爱', '가족에 대한 사랑이 깊다.', 0, '2026-04-18 23:28:09', '2026-04-27 23:27:09');
INSERT INTO `word` VALUES (123, 14, '학교', 'KO', NULL, '学校', '나는 학교에 갑니다.', 0, '2026-04-18 23:28:09', '2026-04-27 23:27:12');
INSERT INTO `word` VALUES (124, 13, 'さようなら', 'JA', 'sayounara', '再见', '明日まで、さようなら！', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (125, 13, 'すみません', 'JA', 'sumimasen', '对不起/打扰一下', 'すみません、道を教えてください。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (126, 13, 'おはよう', 'JA', 'ohayou', '早上好', 'おはようございます！今日も頑張りましょう。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (127, 13, 'こんばんは', 'JA', 'konbanwa', '晚上好', 'こんばんは、ご飯を食べましたか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (128, 13, 'はい', 'JA', 'hai', '是/是的', 'はい、分かりました。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (129, 13, 'いいえ', 'JA', 'iie', '不/不是', 'いいえ、大丈夫ですよ。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (130, 13, 'お願いします', 'JA', 'onegaishimasu', '拜托了/请多关照', 'よろしくお願いします。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (131, 13, 'ごめんなさい', 'JA', 'gomennasai', '对不起', '遅れてごめんなさい。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (132, 13, 'おやすみなさい', 'JA', 'oyasuminasai', '晚安', 'おやすみなさい、良い夢を。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (133, 13, 'いただきます', 'JA', 'itadakimasu', '我开动了', 'いただきます！', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (134, 13, 'ごちそうさまでした', 'JA', 'gochisousamadeshita', '多谢款待', 'ごちそうさまでした！', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (135, 13, 'ただいま', 'JA', 'tadaima', '我回来了', 'ただいま！', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (136, 13, 'おかえり', 'JA', 'okaeri', '欢迎回来', 'おかえりなさい。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (137, 13, 'すごい', 'JA', 'sugoi', '厉害/太棒了', 'すごいですね！', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (138, 13, '大丈夫', 'JA', 'daijoubu', '没关系/没事', '大丈夫ですか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (139, 13, '分かりました', 'JA', 'wakarimashita', '我明白了', 'はい、分かりました。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (140, 13, '分かりません', 'JA', 'wakarimasen', '我不明白', 'すみません、分かりません。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (141, 13, 'もう一度お願いします', 'JA', 'mouichido onegaishimasu', '请再说一遍', 'もう一度ゆっくりお願いします。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (142, 13, '月', 'JA', 'tsuki/gatsu', '月亮/月份', '一月はいちがつです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (143, 13, '日', 'JA', 'hi/nichi', '太阳/日子', '今日は何曜日ですか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (144, 13, '時', 'JA', 'toki/jiji', '时间/点钟', '今何時ですか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (145, 13, '分', 'JA', 'fu/bun', '分钟', '十分待ってください。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (146, 13, '秒', 'JA', 'byou', '秒', '三十秒です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (147, 13, '年', 'JA', 'nen/toshi', '年', '今年は2026年です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (148, 13, '週', 'JA', 'shuu', '周', '一週間休みます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (149, 13, '月曜日', 'JA', 'getsuyoubi', '星期一', '月曜日に学校があります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (150, 13, '火曜日', 'JA', 'kayoubi', '星期二', '火曜日に仕事があります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (151, 13, '水曜日', 'JA', 'suiyoubi', '星期三', '水曜日に映画を見ます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (152, 13, '木曜日', 'JA', 'mokuyoubi', '星期四', '木曜日に買い物に行きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (153, 13, '金曜日', 'JA', 'kinyoubi', '星期五', '金曜日にパーティーがあります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (154, 13, '土曜日', 'JA', 'doyoubi', '星期六', '土曜日に休みです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (155, 13, '日曜日', 'JA', 'nichiyoubi', '星期日', '日曜日に家にいます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (156, 13, '私', 'JA', 'watashi', '我', '私は学生です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (157, 13, 'あなた', 'JA', 'anata', '你', 'あなたは誰ですか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (158, 13, '彼', 'JA', 'kare', '他', '彼は先生です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (159, 13, '彼女', 'JA', 'kanojo', '她', '彼女は医者です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (160, 13, '私たち', 'JA', 'watashitachi', '我们', '私たちは友達です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (161, 13, 'あなたたち', 'JA', 'anatatachi', '你们', 'あなたたちはどこから来ましたか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (162, 13, '彼ら', 'JA', 'karera', '他们', '彼らは学生です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (163, 13, '彼女たち', 'JA', 'kanojotachi', '她们', '彼女たちは公園にいます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (164, 13, 'これ', 'JA', 'kore', '这个', 'これは本です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (165, 13, 'それ', 'JA', 'sore', '那个', 'それはペンです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (166, 13, 'あれ', 'JA', 'are', '那个（远）', 'あれは何ですか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (167, 13, 'この', 'JA', 'kono', '这个（+名词）', 'この本は面白いです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (168, 13, 'その', 'JA', 'sono', '那个（+名词）', 'そのペンをください。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (169, 13, 'あの', 'JA', 'ano', '那个（远+名词）', 'あの人は誰ですか。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (170, 13, 'どれ', 'JA', 'dore', '哪个', 'どれがあなたの傘ですか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (171, 13, 'どの', 'JA', 'dono', '哪个（+名词）', 'どの本が好きですか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (172, 13, '水', 'JA', 'mizu', '水', '水をください。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (173, 13, 'お茶', 'JA', 'ochya', '茶', 'お茶を飲みます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (174, 13, 'コーヒー', 'JA', 'koohii', '咖啡', '朝にコーヒーを飲みます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (175, 13, 'ジュース', 'JA', 'juusu', '果汁', 'りんごジュースが好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (176, 13, '牛乳', 'JA', 'gyuunyuu', '牛奶', '牛乳を飲みます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (177, 13, 'ご飯', 'JA', 'gohan', '米饭', 'ご飯を食べます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (178, 13, 'パン', 'JA', 'pan', '面包', '朝ごはんはパンです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (179, 13, '卵', 'JA', 'tamago', '鸡蛋', '卵を食べます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (180, 13, '肉', 'JA', 'niku', '肉', '肉が好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (181, 13, '魚', 'JA', 'sakana', '鱼', '魚が好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (182, 13, '野菜', 'JA', 'yasai', '蔬菜', '野菜を食べます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (183, 13, '果物', 'JA', 'kudamono', '水果', '果物が好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (184, 13, 'りんご', 'JA', 'ringo', '苹果', 'りんごを食べます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (185, 13, 'バナナ', 'JA', 'banana', '香蕉', 'バナナが好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (186, 13, 'みかん', 'JA', 'mikan', '橘子', 'みかんを食べます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (187, 13, 'いちご', 'JA', 'ichigo', '草莓', 'いちごが大好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (188, 13, 'すし', 'JA', 'sushi', '寿司', 'すしを食べに行きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (189, 13, 'ラーメン', 'JA', 'raamen', '拉面', 'ラーメンが好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (190, 13, 'カレー', 'JA', 'karē', '咖喱', 'カレーライスが好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (191, 13, '本', 'JA', 'hon', '书', '本を読みます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (192, 13, 'ペン', 'JA', 'pen', '钢笔', 'ペンで字を書きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (193, 13, '鉛筆', 'JA', 'enpitsu', '铅笔', '鉛筆で絵を描きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (194, 13, 'ノート', 'JA', 'nōto', '笔记本', 'ノートに書きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (195, 13, '辞書', 'JA', 'jisho', '字典', '辞書を使います。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (196, 13, '鞄', 'JA', 'kaban', '包', '鞄を持ちます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (197, 13, '時計', 'JA', 'tokei', '手表/时钟', '時計を見ます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (198, 13, '携帯電話', 'JA', 'keitaidenwa', '手机', '携帯電話を持っています。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (199, 13, 'コンピューター', 'JA', 'konpyuutaa', '电脑', 'コンピューターを使います。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (200, 13, 'テレビ', 'JA', 'terebi', '电视', 'テレビを見ます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (201, 13, '冷蔵庫', 'JA', 'reizouko', '冰箱', '冷蔵庫にビールがあります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (202, 13, '机', 'JA', 'tsukue', '桌子', '机の上に本があります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (203, 13, '椅子', 'JA', 'isu', '椅子', '椅子に座ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (204, 13, 'ベッド', 'JA', 'beddo', '床', 'ベッドで寝ます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (205, 13, 'ドア', 'JA', 'doa', '门', 'ドアを開けます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (206, 13, '窓', 'JA', 'mado', '窗户', '窓を閉めます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (207, 13, '家', 'JA', 'ie', '家', '家に帰ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (208, 13, '学校', 'JA', 'gakkou', '学校', '学校に行きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (209, 13, '会社', 'JA', 'kaisha', '公司', '会社に行きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (210, 13, '公園', 'JA', 'kouen', '公园', '公園で散歩します。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (211, 13, '図書館', 'JA', 'toshokan', '图书馆', '図書館で本を借ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (212, 13, '病院', 'JA', 'byouin', '医院', '病院に行きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (213, 13, '店', 'JA', 'mise', '店', '店で買い物をします。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (214, 13, '駅', 'JA', 'eki', '车站', '駅で電車に乗ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (215, 13, '銀行', 'JA', 'ginkou', '银行', '銀行に行きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (216, 13, '郵便局', 'JA', 'yuubinkyoku', '邮局', '郵便局に手紙を出します。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (217, 13, '食べる', 'JA', 'taberu', '吃', 'ご飯を食べます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (218, 13, '飲む', 'JA', 'nomu', '喝', '水を飲みます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (219, 13, '見る', 'JA', 'mito', '看', 'テレビを見ます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (220, 13, '聞く', 'JA', 'kiku', '听', '音楽を聞きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (221, 13, '読む', 'JA', 'yomu', '读', '本を読みます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (222, 13, '書く', 'JA', 'kaku', '写', '字を書きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (223, 13, '話す', 'JA', 'hanasu', '说', '日本語を話します。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (224, 13, '行く', 'JA', 'iku', '去', '学校に行きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (225, 13, '来る', 'JA', 'kiru', '来', '家に来ます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (226, 13, '帰る', 'JA', 'kaeru', '回', '家に帰ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (227, 13, '寝る', 'JA', 'neru', '睡', '夜に寝ます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (228, 13, '起きる', 'JA', 'okiru', '起床', '朝に起きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (229, 13, '働く', 'JA', 'hataraku', '工作', '会社で働きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (230, 13, '勉強する', 'JA', 'benkyousuru', '学习', '日本語を勉強します。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (231, 13, '買う', 'JA', 'kau', '买', '店で本を買います。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (232, 13, '売る', 'JA', 'uru', '卖', '本を売ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (233, 13, '持つ', 'JA', 'motsu', '拿', '鞄を持ちます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (234, 13, '開ける', 'JA', 'akeru', '打开', 'ドアを開けます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (235, 13, '閉める', 'JA', 'shimeru', '关闭', '窓を閉めます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (236, 13, '座る', 'JA', 'suwaru', '坐', '椅子に座ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (237, 13, '立つ', 'JA', 'tatsu', '站', '立ってください。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (238, 13, '走る', 'JA', 'hashiru', '跑', '公園で走ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (239, 13, '歩く', 'JA', 'aruku', '走/步行', '駅まで歩きます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (240, 13, '歌う', 'JA', 'utau', '唱歌', '歌を歌います。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (241, 13, '踊る', 'JA', 'odoru', '跳舞', '踊りを踊ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (242, 13, '好き', 'JA', 'suki', '喜欢', '音楽が好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (243, 13, '嫌い', 'JA', 'kirai', '讨厌', '野菜が嫌いです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (244, 13, '大きい', 'JA', 'ookii', '大的', '大きい犬がいます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (245, 13, '小さい', 'JA', 'chiisai', '小的', '小さい猫がいます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (246, 13, '高い', 'JA', 'takai', '高的/贵的', '高い建物があります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (247, 13, '低い', 'JA', 'hikui', '低的/便宜的', '低い机があります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (248, 13, '長い', 'JA', 'nagai', '长的', '長い髪が好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (249, 13, '短い', 'JA', 'mijikai', '短的', '短い髪が好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (250, 13, '新しい', 'JA', 'atarashii', '新的', '新しい本を買いました。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (251, 13, '古い', 'JA', 'furui', '旧的', '古い車があります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (252, 13, '白い', 'JA', 'shiroi', '白色的', '白い猫がいます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (253, 13, '黒い', 'JA', 'kuroi', '黑色的', '黒い犬がいます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (254, 13, '赤い', 'JA', 'akai', '红色的', '赤いりんごがあります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (255, 13, '青い', 'JA', 'aoi', '蓝色的', '青い空がきれいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (256, 13, '黄色い', 'JA', 'kiiroi', '黄色的', '黄色いバナナがあります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (257, 13, '緑の', 'JA', 'midorino', '绿色的', '緑の木があります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (258, 13, 'きれい', 'JA', 'kirei', '漂亮的/干净的', 'きれいな花があります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (259, 13, '汚い', 'JA', 'kitanai', '脏的', '汚い服を洗います。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (260, 13, '暑い', 'JA', 'atsui', '热的', '夏は暑いです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (261, 13, '寒い', 'JA', 'samui', '冷的', '冬は寒いです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (262, 13, '暖かい', 'JA', 'atatakai', '温暖的', '春は暖かいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (263, 13, '涼しい', 'JA', 'suzushii', '凉爽的', '秋は涼しいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (264, 13, '美味しい', 'JA', 'oishii', '好吃的', 'この料理は美味しいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (265, 13, 'まずい', 'JA', 'mazui', '难吃的', 'この料理はまずいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (266, 13, '難しい', 'JA', 'muzukashii', '难的', '日本語は難しいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (267, 13, '易しい', 'JA', 'yasashii', '容易的/温柔的', 'この本は易しいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (268, 13, '楽しい', 'JA', 'tanoshii', '快乐的', '旅行は楽しいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (269, 13, '悲しい', 'JA', 'kanashii', '悲伤的', '悲しいニュースです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (270, 13, '嬉しい', 'JA', 'ureshii', '高兴的', '嬉しいです！', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (271, 13, '忙しい', 'JA', 'isogashii', '忙的', '今日は忙しいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (272, 13, '暇', 'JA', 'hima', '空闲的', '明日は暇です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (273, 13, '元気', 'JA', 'genki', '健康的/有精神的', 'お元気ですか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (274, 13, 'とても', 'JA', 'totemo', '非常', 'とても美味しいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (275, 13, '少し', 'JA', 'sukoshi', '一点', '少し待ってください。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (276, 13, 'もう', 'JA', 'mou', '已经', 'もう食べました。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (277, 13, 'まだ', 'JA', 'mada', '还', 'まだ食べていません。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (278, 13, 'いつ', 'JA', 'itsu', '什么时候', 'いつ行きますか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (279, 13, 'どこ', 'JA', 'doko', '哪里', 'どこに行きますか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (280, 13, '何', 'JA', 'nani', '什么', '何を食べますか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (281, 13, '誰', 'JA', 'dare', '谁', '誰が来ますか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (282, 13, 'どうして', 'JA', 'doushite', '为什么', 'どうして遅れましたか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (283, 13, 'どう', 'JA', 'dou', '怎么样', 'これはどうですか？', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (284, 13, '父', 'JA', 'chichi', '父亲', '父は会社員です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (285, 13, '母', 'JA', 'haha', '母亲', '母は主婦です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (286, 13, '兄', 'JA', 'ani', '哥哥', '兄は医者です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (287, 13, '姉', 'JA', 'ane', '姐姐', '姉は先生です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (288, 13, '弟', 'JA', 'otouto', '弟弟', '弟は学生です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (289, 13, '妹', 'JA', 'imouto', '妹妹', '妹は小学生です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (290, 13, '祖父', 'JA', 'sofu', '祖父', '祖父は80歳です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (291, 13, '祖母', 'JA', 'sobo', '祖母', '祖母は元気です。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (292, 13, '息子', 'JA', 'musuko', '儿子', '息子が一人います。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (293, 13, '娘', 'JA', 'musume', '女儿', '娘が二人います。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (294, 13, '犬', 'JA', 'inu', '狗', '犬が好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (295, 13, '猫', 'JA', 'neko', '猫', '猫が好きです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (296, 13, '鳥', 'JA', 'tori', '鸟', '鳥が飛んでいます。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (297, 13, '花', 'JA', 'hana', '花', '花が咲いています。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (298, 13, '木', 'JA', 'ki', '树', '木がたくさんあります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (299, 13, '空', 'JA', 'sora', '天空', '青い空がきれいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (300, 13, '海', 'JA', 'umi', '大海', '海に行きたいです。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (301, 13, '山', 'JA', 'yama', '山', '山に登ります。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (302, 13, '雨', 'JA', 'ame', '雨', '雨が降っています。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (303, 13, '雪', 'JA', 'yuki', '雪', '雪が降っています。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (304, 13, '風', 'JA', 'kaze', '风', '風が吹いています。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (305, 13, '太陽', 'JA', 'taiyou', '太阳', '太陽が輝いています。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (306, 13, '星', 'JA', 'hoshi', '星星', '星が輝いています。', 1, '2026-04-19 00:08:03', '2026-04-19 00:08:03');
INSERT INTO `word` VALUES (312, 1, '﻿ability', 'EN', '/əˈbɪləti/', 'n.能力；才能', 'She has the ability to solve complex problems.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (313, 1, 'abroad', 'EN', '/əˈbrɔːd/', 'adv.到国外；在国外', 'He went abroad to study English last year.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (314, 1, 'absent', 'EN', '/ˈæbsənt/', 'adj.缺席的；不在场的', 'He was absent from class because he was ill.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (315, 1, 'absolute', 'EN', '/ˈæbsəluːt/', 'adj.绝对的；完全的', 'There is no absolute standard for beauty.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (316, 1, 'absorb', 'EN', '/əbˈzɔːb/', 'v.吸收；吸引', 'Plants absorb water and nutrients from the soil.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (317, 1, 'abstract', 'EN', '/ˈæbstrækt/', 'adj.抽象的；摘要', 'It is difficult to understand this abstract concept.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (318, 1, 'abundant', 'EN', '/əˈbʌndənt/', 'adj.大量的；丰富的', 'The region has abundant natural resources.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (319, 1, 'abuse', 'EN', '/əˈbjuːz/', 'v.滥用；虐待', 'He was accused of abusing his power.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (320, 1, 'academic', 'EN', '/ˌækəˈdemɪk/', 'adj.学术的；学院的', 'She works in an academic research institute.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (321, 1, 'accelerate', 'EN', '/əkˈseləreɪt/', 'v.加速；促进', 'The car accelerated quickly on the highway.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (322, 1, 'access', 'EN', '/ˈækses/', 'n.通道；使用权；v.访问', 'Students have free access to the library.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (323, 1, 'accident', 'EN', '/ˈæksɪdənt/', 'n.事故；意外事件', 'He was injured in a car accident last week.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (324, 1, 'accommodate', 'EN', '/əˈkɒmədeɪt/', 'v.容纳；适应；提供住宿', 'The hotel can accommodate 200 guests.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (325, 1, 'accommodation', 'EN', '/əˌkɒməˈdeɪʃn/', 'n.住宿；膳宿', 'We need to find accommodation for the night.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (326, 1, 'accompany', 'EN', '/əˈkʌmpəni/', 'v.陪伴；伴随；伴奏', 'She will accompany her mother to the hospital.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (327, 1, 'accomplish', 'EN', '/əˈkʌmplɪʃ/', 'v.完成；实现', 'We accomplished all the tasks ahead of schedule.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (328, 1, 'accord', 'EN', '/əˈkɔːd/', 'n.协议；v.给予；符合', 'We reached an accord on this issue.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (329, 1, 'accordance', 'EN', '/əˈkɔːdns/', 'n.一致；符合', 'We must act in accordance with the rules.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (330, 1, 'accordingly', 'EN', '/əˈkɔːdɪŋli/', 'adv.因此；相应lyly', 'He was ill, and accordingly he couldn\'t come.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (331, 1, 'account', 'EN', '/əˈkaʊnt/', 'n.账户；描述；v.解释', 'She gave a detailed account of the incident.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (332, 1, 'accumulate', 'EN', '/əˈkjuːmjəleɪt/', 'v.积累；积聚', 'Dust accumulated on the desk during the holiday.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (333, 1, 'accurate', 'EN', '/ˈækjərət/', 'adj.准确的；精确的', 'We need accurate data to make decisions.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (334, 1, 'accuse', 'EN', '/əˈkjuːz/', 'v.指责；控告', 'He was accused of stealing money from the company.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (335, 1, 'achievement', 'EN', '/əˈtʃiːvmənt/', 'n.成就；成绩', 'Winning the prize is a great achievement for him.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (336, 1, 'acid', 'EN', '/ˈæsɪd/', 'n.酸；adj.酸的；酸性的', 'Lemon juice has an acid taste.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (337, 1, 'acknowledge', 'EN', '/əkˈnɒlɪdʒ/', 'v.承认；致谢', 'He refused to acknowledge his mistake.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (338, 1, 'acquire', 'EN', '/əˈkwaɪə(r)/', 'v.获得；习得', 'She acquired a lot of knowledge from reading.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (339, 1, 'adapt', 'EN', '/əˈdæpt/', 'v.适应；改编', 'Animals need to adapt to their environment.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (340, 1, 'adjust', 'EN', '/əˈdʒʌst/', 'v.调整；校正；适应', 'Please adjust the temperature of the air conditioner.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (341, 1, 'administration', 'EN', '/ədˌmɪnɪˈstreɪʃn/', 'n.管理；行政部门', 'The school administration made new rules.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (342, 1, 'admit', 'EN', '/ədˈmɪt/', 'v.承认；允许进入', 'He finally admitted that he was wrong.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (343, 1, 'adopt', 'EN', '/əˈdɒpt/', 'v.采用；收养；采纳', 'They decided to adopt a homeless child.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (344, 1, 'advance', 'EN', '/ədˈvɑːns/', 'v.前进；促进；n.进步', 'Technology has advanced rapidly in recent years.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (345, 1, 'advanced', 'EN', '/ədˈvɑːnst/', 'adj.先进的；高级的', 'She is taking an advanced English course.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (346, 1, 'advantage', 'EN', '/ədˈvɑːntɪdʒ/', 'n.优势；有利条件', 'Being bilingual is a big advantage in this job.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (347, 1, 'adventure', 'EN', '/ədˈventʃə(r)/', 'n.冒险；奇遇', 'They went on an adventure in the mountains.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (348, 1, 'advertise', 'EN', '/ˈædvətaɪz/', 'v.做广告；宣传', 'The company advertised its new product on TV.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (349, 1, 'advertisement', 'EN', '/ədˈvɜːtɪsmənt/', 'n.广告；宣传', 'I saw an advertisement for a new phone.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (350, 1, 'advisable', 'EN', '/ədˈvaɪzəbl/', 'adj.明智的；可取的', 'It is advisable to book tickets in advance.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (351, 1, 'advise', 'EN', '/ədˈvaɪz/', 'v.建议；劝告；通知', 'The doctor advised him to rest more.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (352, 1, 'advocate', 'EN', '/ˈædvəkeɪt/', 'v.提倡；拥护；n.倡导者', 'She advocates for environmental protection.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (353, 1, 'affect', 'EN', '/əˈfekt/', 'v.影响；打动；使感染', 'The bad weather affected the flight schedule.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (354, 1, 'afford', 'EN', '/əˈfɔːd/', 'v.买得起；承担得起', 'I can\'t afford to buy a new car right now.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (355, 1, 'agency', 'EN', '/ˈeɪdʒənsi/', 'n.代理机构；政府机构', 'She works at a travel agency.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (356, 1, 'agenda', 'EN', '/əˈdʒendə/', 'n.议程；日程安排', 'What\'s on the agenda for today\'s meeting?', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (357, 1, 'agent', 'EN', '/ˈeɪdʒənt/', 'n.代理人；代理商；剂', 'He is a real estate agent.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (358, 1, 'aggressive', 'EN', '/əˈɡresɪv/', 'adj.侵略性的；有进取心的', 'He is an aggressive businessman.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (359, 1, 'aid', 'EN', '/eɪd/', 'n.援助；帮助；v.帮助；援助', 'The Red Cross provided aid to the victims.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (360, 1, 'aim', 'EN', '/eɪm/', 'n.目标；目的；v.瞄准；旨在', 'Our aim is to improve customer satisfaction.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (361, 1, 'aircraft', 'EN', '/ˈeəkrɑːft/', 'n.飞机；航空器', 'The aircraft took off on time.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (362, 1, 'alarm', 'EN', '/əˈlɑːm/', 'n.警报；闹钟；v.使惊恐', 'The fire alarm went off in the middle of the night.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (363, 1, 'album', 'EN', '/ˈælbəm/', 'n.相册；唱片集', 'She keeps her photos in an album.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (364, 1, 'alert', 'EN', '/əˈlɜːt/', 'adj.警觉的；n.警报；v.提醒', 'The guard remained alert throughout the night.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (365, 1, 'alien', 'EN', '/ˈeɪliən/', 'n.外星人；外国人；adj.外国的', 'Many people believe in alien life.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (366, 1, 'align', 'EN', '/əˈlaɪn/', 'v.使对齐；使一致', 'Please align the text to the left.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (367, 1, 'alike', 'EN', '/əˈlaɪk/', 'adj.相像的；adv.同样地', 'The two sisters look very alike.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (368, 1, 'alive', 'EN', '/əˈlaɪv/', 'adj.活着的；有活力的', 'Is there anyone alive in the building?', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (369, 1, 'alliance', 'EN', '/əˈlaɪəns/', 'n.联盟；同盟', 'The countries formed an alliance to fight the war.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (370, 1, 'allocate', 'EN', '/ˈæləkeɪt/', 'v.分配；划拨', 'The company allocated funds for the new project.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (371, 1, 'allow', 'EN', '/əˈlaʊ/', 'v.允许；准许；承认', 'Smoking is not allowed in this building.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (372, 1, 'allowance', 'EN', '/əˈlaʊəns/', 'n.津贴；补贴；限额', 'He receives a monthly allowance from his parents.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (373, 1, 'ally', 'EN', '/ˈælaɪ/', 'n.盟友；同盟国；v.结盟', 'The two countries became allies during the war.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (374, 1, 'alter', 'EN', '/ˈɔːltə(r)/', 'v.改变；改动', 'We need to alter our plans due to the bad weather.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (375, 1, 'alternative', 'EN', '/ɔːlˈtɜːnətɪv/', 'adj.可供选择的；n.选择', 'Is there an alternative way to solve this problem?', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (376, 1, 'altitude', 'EN', '/ˈæltɪtjuːd/', 'n.海拔；高度', 'The plane flew at an altitude of 10,000 meters.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (377, 1, 'amateur', 'EN', '/ˈæmətə(r)/', 'n.业余爱好者；adj.业余的', 'He is an amateur photographer.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (378, 1, 'amaze', 'EN', '/əˈmeɪz/', 'v.使惊奇；使惊愕', 'Her performance amazed everyone in the audience.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (379, 1, 'ambition', 'EN', '/æmˈbɪʃn/', 'n.野心；抱负；志向', 'She has a great ambition to become a famous writer.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (380, 1, 'ambitious', 'EN', '/æmˈbɪʃəs/', 'adj.有抱负的；野心勃勃的', 'He is an ambitious young man who wants to succeed.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (381, 1, 'ambulance', 'EN', '/ˈæmbjələns/', 'n.救护车', 'We called an ambulance when he had a heart attack.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (382, 1, 'amend', 'EN', '/əˈmend/', 'v.修改；修订；改进', 'The government plans to amend the law.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (383, 1, 'amount', 'EN', '/əˈmaʊnt/', 'n.数量；总额；v.总计；等于', 'The total amount of money we need is $1000.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (384, 1, 'amuse', 'EN', '/əˈmjuːz/', 'v.逗乐；使愉快；消遣', 'The children were amused by the clown\'s tricks.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (385, 1, 'analyse', 'EN', '/ˈænəlaɪz/', 'v.分析；研究', 'We need to analyse the data before making a decision.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (386, 1, 'analysis', 'EN', '/əˈnæləsɪs/', 'n.分析；分解', 'The report includes a detailed analysis of the problem.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (387, 1, 'ancestor', 'EN', '/ˈænsestə(r)/', 'n.祖先；祖宗', 'My ancestors came from Europe.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (388, 1, 'anchor', 'EN', '/ˈæŋkə(r)/', 'n.锚；v.抛锚；固定', 'The ship dropped anchor in the harbor.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (389, 1, 'ancient', 'EN', '/ˈeɪnʃənt/', 'adj.古代的；古老的', 'We visited an ancient castle in the countryside.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (390, 1, 'angle', 'EN', '/ˈæŋɡl/', 'n.角度；角；观点', 'Let\'s look at the problem from a different angle.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (391, 1, 'ankle', 'EN', '/ˈæŋkl/', 'n.脚踝；踝关节', 'He sprained his ankle while playing basketball.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (392, 1, 'announce', 'EN', '/əˈnaʊns/', 'v.宣布；宣告；通知', 'The company announced a new product launch.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (393, 1, 'annoy', 'EN', '/əˈnɔɪ/', 'v.使恼怒；打扰', 'It annoys me when people are late.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (394, 1, 'annual', 'EN', '/ˈænjuəl/', 'adj.每年的；年度的；n.年报', 'The company held its annual meeting last week.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (395, 1, 'anticipate', 'EN', '/ænˈtɪsɪpeɪt/', 'v.预期；预料；期望', 'We didn\'t anticipate so many people coming.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (396, 1, 'anxiety', 'EN', '/æŋˈzaɪəti/', 'n.焦虑；担忧；渴望', 'She felt a lot of anxiety before the exam.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (397, 1, 'anxious', 'EN', '/ˈæŋkʃəs/', 'adj.焦虑的；担忧的；渴望的', 'He is anxious to know the exam results.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (398, 1, 'apart', 'EN', '/əˈpɑːt/', 'adv.分开；相距；adj.分离的', 'The two cities are 100 kilometers apart.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (399, 1, 'apartment', 'EN', '/əˈpɑːtmənt/', 'n.公寓套房；单元房', 'She lives in a small apartment in the city.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (400, 1, 'apologise', 'EN', '/əˈpɒlədʒaɪz/', 'v.道歉；认错', 'He apologised for being late to the meeting.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (401, 1, 'apology', 'EN', '/əˈpɒlədʒi/', 'n.道歉；歉意', 'Please accept my sincere apology for the mistake.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (402, 1, 'apparent', 'EN', '/əˈpærənt/', 'adj.明显的；表面上的', 'It is apparent that he is not happy with the result.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (403, 1, 'appeal', 'EN', '/əˈpiːl/', 'v.呼吁；上诉；吸引；n.呼吁', 'The charity is appealing for donations.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (404, 1, 'appear', 'EN', '/əˈpɪə(r)/', 'v.出现；显得；发表', 'A new star appeared in the sky last night.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (405, 1, 'appearance', 'EN', '/əˈpɪərəns/', 'n.外貌；外观；出现', 'She cares a lot about her appearance.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (406, 1, 'appetite', 'EN', '/ˈæpɪtaɪt/', 'n.食欲；胃口；欲望', 'He has a good appetite today.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (407, 1, 'applaud', 'EN', '/əˈplɔːd/', 'v.鼓掌；称赞；赞许', 'The audience applauded loudly at the end of the show.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (408, 1, 'application', 'EN', '/ˌæplɪˈkeɪʃn/', 'n.申请；应用；用途', 'She submitted her job application yesterday.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (409, 1, 'apply', 'EN', '/əˈplaɪ/', 'v.申请；应用；适用', 'I plan to apply for a scholarship next semester.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (410, 1, 'appoint', 'EN', '/əˈpɔɪnt/', 'v.任命；委派；约定', 'The company appointed a new CEO last month.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (411, 1, 'appointment', 'EN', '/əˈpɔɪntmənt/', 'n.约会；预约；任命', 'I have an appointment with the doctor at 3 PM.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (412, 1, 'appraise', 'EN', '/əˈpreɪz/', 'v.评价；评估；估价', 'The house was appraised at $500,000.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (413, 1, 'appreciate', 'EN', '/əˈpriːʃieɪt/', 'v.欣赏；感激；重视', 'I really appreciate your help with the project.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (414, 1, 'appropriate', 'EN', '/əˈprəʊpriət/', 'adj.适当的；合适的；v.挪用', 'Please wear appropriate clothes for the interview.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (415, 1, 'approve', 'EN', '/əˈpruːv/', 'v.批准；认可；赞成', 'The committee approved the new plan.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (416, 1, 'approximate', 'EN', '/əˈprɒksɪmət/', 'adj.近似的；大约的；v.接近', 'The approximate time of arrival is 5 PM.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (417, 1, 'arbitrary', 'EN', '/ˈɑːbɪtrəri/', 'adj.任意的；武断的；专断的', 'His decision was completely arbitrary.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (418, 1, 'architect', 'EN', '/ˈɑːkɪtekt/', 'n.建筑师；设计师', 'She works as an architect in a big firm.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (419, 1, 'architecture', 'EN', '/ˈɑːkɪtektʃə(r)/', 'n.建筑学；建筑风格', 'I love the architecture of old European cities.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (420, 1, 'area', 'EN', '/ˈeəriə/', 'n.区域；地区；面积；领域', 'We live in a quiet residential area.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (421, 1, 'argue', 'EN', '/ˈɑːɡjuː/', 'v.争论；争辩；主张', 'They argued about the best way to solve the problem.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (422, 1, 'argument', 'EN', '/ˈɑːɡjumənt/', 'n.争论；争吵；论点', 'We had a heated argument about politics.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (423, 1, 'arise', 'EN', '/əˈraɪz/', 'v.出现；产生；起身', 'New problems will arise as the project progresses.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (424, 1, 'arithmetic', 'EN', '/əˈrɪθmətɪk/', 'n.算术；计算；adj.算术的', 'He is good at arithmetic and math problems.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (425, 1, 'army', 'EN', '/ˈɑːmi/', 'n.军队；陆军；大批', 'The army was sent to the border to maintain peace.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (426, 1, 'arouse', 'EN', '/əˈraʊz/', 'v.引起；唤起；唤醒', 'Her speech aroused the audience\'s interest.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (427, 1, 'arrange', 'EN', '/əˈreɪndʒ/', 'v.安排；布置；筹划', 'We need to arrange a meeting with the team.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (428, 1, 'arrangement', 'EN', '/əˈreɪndʒmənt/', 'n.安排；布置；约定', 'Thank you for making the travel arrangements.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (429, 1, 'arrest', 'EN', '/əˈrest/', 'v.逮捕；拘留；阻止；n.逮捕', 'The police arrested the suspect last night.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (430, 1, 'arrive', 'EN', '/əˈraɪv/', 'v.到达；抵达；来临', 'We arrived at the station just in time for the train.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (431, 1, 'arrow', 'EN', '/ˈærəʊ/', 'n.箭；箭头；箭号；v.快速移动', 'Follow the arrow to the exit.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (432, 1, 'artificial', 'EN', '/ˌɑːtɪˈfɪʃl/', 'adj.人工的；人造的；虚假的', 'She wears artificial flowers in her hair.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (433, 1, 'aspect', 'EN', '/ˈæspekt/', 'n.方面；层面；外观；朝向', 'We need to consider all aspects of the problem.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (434, 1, 'assemble', 'EN', '/əˈsembl/', 'v.集合；组装；装配', 'We need to assemble the furniture this afternoon.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (435, 1, 'assembly', 'EN', '/əˈsembli/', 'n.集会；组装；装配；议会', 'The assembly line produces 100 cars a day.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (436, 1, 'assess', 'EN', '/əˈses/', 'v.评估；评价；评定', 'The teacher will assess our work at the end of the semester.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (437, 1, 'asset', 'EN', '/ˈæset/', 'n.资产；财产；优点；长处', 'Good communication skills are a great asset in this job.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (438, 1, 'assign', 'EN', '/əˈsaɪn/', 'v.分配；指派；布置；指定', 'The teacher assigned us a new homework project.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (439, 1, 'assignment', 'EN', '/əˈsaɪnmənt/', 'n.任务；作业；分配；指派', 'I have a lot of assignments to finish this weekend.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (440, 1, 'assist', 'EN', '/əˈsɪst/', 'v.帮助；协助；援助；n.助手', 'She will assist me with the presentation.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (441, 1, 'assistance', 'EN', '/əˈsɪstəns/', 'n.帮助；协助；援助', 'We need your assistance to complete the project on time.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (442, 1, 'assistant', 'EN', '/əˈsɪstənt/', 'n.助手；助理；adj.辅助的', 'He works as an assistant to the manager.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (443, 1, 'associate', 'EN', '/əˈsəʊʃieɪt/', 'v.联系；关联；交往；n.同事', 'I don\'t associate with people who lie.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (444, 1, 'association', 'EN', '/əˌsəʊsiˈeɪʃn/', 'n.协会；社团；关联；联系', 'She is a member of the student association.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (445, 1, 'assume', 'EN', '/əˈsjuːm/', 'v.假定；假设；承担；认为', 'I assume you will be coming to the party tonight.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (446, 1, 'assumption', 'EN', '/əˈsʌmpʃn/', 'n.假定；假设；承担；假装', 'His assumption turned out to be wrong.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (447, 1, 'assure', 'EN', '/əˈʃʊə(r)/', 'v.使确信；保证；确保', 'I assure you that the product is safe to use.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (448, 1, 'astonish', 'EN', '/əˈstɒnɪʃ/', 'v.使惊讶；使吃惊', 'Her sudden decision to quit her job astonished everyone.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (449, 1, 'athlete', 'EN', '/ˈæθliːt/', 'n.运动员；体育健儿', 'He is a professional athlete who runs marathons.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (450, 1, 'atmosphere', 'EN', '/ˈætməsfɪə(r)/', 'n.大气；空气；气氛；氛围', 'The restaurant has a warm and friendly atmosphere.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (451, 1, 'atom', 'EN', '/ˈætəm/', 'n.原子；微粒；微量', 'Water is made up of two hydrogen atoms and one oxygen atom.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (452, 1, 'attach', 'EN', '/əˈtætʃ/', 'v.附上；贴上；使依附；重视', 'Please attach the document to your email.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (453, 1, 'attack', 'EN', '/əˈtæk/', 'v.攻击；袭击；抨击；n.攻击', 'The enemy attacked the city at dawn.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (454, 1, 'attain', 'EN', '/əˈteɪn/', 'v.达到；获得；实现', 'She attained her dream of becoming a pilot.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (455, 1, 'attempt', 'EN', '/əˈtempt/', 'v.尝试；试图；n.尝试；努力', 'He made an attempt to climb the mountain.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (456, 1, 'attend', 'EN', '/əˈtend/', 'v.出席；参加；照料；专心于', 'We will attend the meeting tomorrow morning.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (457, 1, 'attention', 'EN', '/əˈtenʃn/', 'n.注意；注意力；关注；照料', 'Please pay attention to the teacher\'s instructions.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (458, 1, 'attitude', 'EN', '/ˈætɪtjuːd/', 'n.态度；看法；姿势', 'She has a positive attitude towards life.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (459, 1, 'attract', 'EN', '/əˈtrækt/', 'v.吸引；引起；诱惑', 'The new movie attracted a lot of attention.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (460, 1, 'attraction', 'EN', '/əˈtrækʃn/', 'n.吸引；吸引力；景点；诱惑', 'The Eiffel Tower is a famous tourist attraction.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (461, 1, 'attractive', 'EN', '/əˈtræktɪv/', 'adj.有吸引力的；迷人的；有魅力的', 'She is an attractive young woman with a great smile.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (462, 1, 'attribute', 'EN', '/əˈtrɪbjuːt/', 'v.把…归因于；认为…属于；n.属性', 'He attributes his success to hard work.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (463, 1, 'audience', 'EN', '/ˈɔːdiəns/', 'n.观众；听众；读者', 'The audience clapped loudly at the end of the play.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (464, 1, 'audio', 'EN', '/ˈɔːdiəʊ/', 'adj.声音的；音频的；n.音频；声音', 'We need good audio equipment for the presentation.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (465, 1, 'author', 'EN', '/ˈɔːθə(r)/', 'n.作者；作家；创始人；发起人', 'Who is the author of this novel?', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (466, 1, 'authority', 'EN', '/ɔːˈθɒrəti/', 'n.权力；权威；当局；官方', 'You need permission from the local authority to build here.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (467, 1, 'auto', 'EN', '/ˈɔːtəʊ/', 'n.汽车；adj.自动的', 'The auto industry is developing rapidly in China.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (468, 1, 'automatic', 'EN', '/ˌɔːtəˈmætɪk/', 'adj.自动的；无意识的；必然的；n.自动装置', 'This camera has an automatic focus function.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (469, 1, 'automobile', 'EN', '/ˈɔːtəməbiːl/', 'n.汽车；机动车', 'He works in an automobile manufacturing factory.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (470, 1, 'available', 'EN', '/əˈveɪləbl/', 'adj.可获得的；有空的；有效的', 'The tickets for the concert are no longer available.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (471, 1, 'average', 'EN', '/ˈævərɪdʒ/', 'n.平均；平均数；adj.平均的；普通的', 'The average temperature in summer is 30 degrees.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (472, 1, 'avoid', 'EN', '/əˈvɔɪd/', 'v.避免；避开；防止；回避', 'You should avoid eating too much junk food.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (473, 1, 'await', 'EN', '/əˈweɪt/', 'v.等待；等候；期待；将降临于', 'We are awaiting your reply to our email.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (474, 1, 'awake', 'EN', '/əˈweɪk/', 'adj.醒着的；清醒的；v.醒来；唤醒', 'I was awake all night thinking about the exam.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (475, 1, 'award', 'EN', '/əˈwɔːd/', 'n.奖品；奖金；v.授予；判给；判定', 'She won an award for her outstanding performance.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (476, 1, 'aware', 'EN', '/əˈweə(r)/', 'adj.意识到的；知道的；察觉到的', 'He is not aware of the problem with the project.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (477, 1, 'awful', 'EN', '/ˈɔːfl/', 'adj.糟糕的；可怕的；极坏的', 'I feel awful about what happened yesterday.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (478, 1, 'awkward', 'EN', '/ˈɔːkwəd/', 'adj.尴尬的；笨拙的；棘手的；难处理的', 'He felt awkward when he met her parents for the first time.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (479, 1, 'background', 'EN', '/ˈbækɡraʊnd/', 'n.背景；背景资料；出身；经历', 'She has a strong educational background in science.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (480, 1, 'balance', 'EN', '/ˈbæləns/', 'n.平衡；均衡；余额；v.使平衡；权衡', 'It\'s important to balance work and life.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (481, 1, 'balloon', 'EN', '/bəˈluːn/', 'n.气球；热气球；v.膨胀；激增；adj.气球状的', 'The children are playing with colorful balloons.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (482, 1, 'bargain', 'EN', '/ˈbɑːɡən/', 'n.交易；便宜货；v.讨价还价；谈判', 'I got a good bargain on this dress at the store.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (483, 1, 'base', 'EN', '/beɪs/', 'n.基础；基地；底部；v.以…为基础；adj.基础的', 'The company has its base in Shanghai.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (484, 1, 'basic', 'EN', '/ˈbeɪsɪk/', 'adj.基本的；基础的；n.基础；基本原理', 'We learned basic English grammar in middle school.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (485, 1, 'basis', 'EN', '/ˈbeɪsɪs/', 'n.基础；根据；基准；原则', 'We need to make a decision on the basis of facts.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (486, 1, 'behalf', 'EN', '/bɪˈhɑːf/', 'n.代表；利益；方面', 'I am speaking on behalf of my colleagues.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (487, 1, 'behave', 'EN', '/bɪˈheɪv/', 'v.表现；举止；行为；运转；起作用', 'Please behave yourself at the party tonight.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (488, 1, 'behavior', 'EN', '/bɪˈheɪvjə/', 'n.行为；举止；态度；反应', 'His behavior at the meeting was very rude.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (489, 1, 'benefit', 'EN', '/ˈbenɪfɪt/', 'n.益处；好处；v.有益于；受益', 'Regular exercise benefits both body and mind.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (490, 1, 'bend', 'EN', '/bend/', 'v.弯曲；弯腰；屈服；n.弯曲；转弯', 'He bent down to pick up the pen from the floor.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (491, 1, 'beneath', 'EN', '/bɪˈniːθ/', 'prep.在…下方；低于；adv.在下方；在底下', 'The river flows beneath the bridge.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (492, 1, 'beneficial', 'EN', '/ˌbenɪˈfɪʃl/', 'adj.有益的；有利的；有帮助的', 'Drinking enough water is beneficial to your health.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (493, 1, 'bias', 'EN', '/ˈbaɪəs/', 'n.偏见；偏爱；v.使有偏见；adj.有偏见的', 'We should avoid bias when making decisions.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (494, 1, 'bid', 'EN', '/bɪd/', 'v.出价；投标；n.出价；投标；尝试', 'He made a bid for the painting at the auction.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (495, 1, 'bind', 'EN', '/baɪnd/', 'v.捆绑；装订；约束；n.困境；束缚', 'She bound the package with string.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (496, 1, 'biology', 'EN', '/baɪˈɒlədʒi/', 'n.生物学；生物；生态学', 'She is studying biology at university.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (497, 1, 'birth', 'EN', '/bɜːθ/', 'n.出生；诞生；分娩；起源；出身', 'The baby\'s birth was a happy event for the family.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (498, 1, 'blame', 'EN', '/bleɪm/', 'v.责备；指责；n.责备；责任；过失', 'Don\'t blame me for your mistake.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (499, 1, 'blank', 'EN', '/blæŋk/', 'adj.空白的；茫然的；n.空白；空格；表格', 'Please fill in the blank with the correct word.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (500, 1, 'blast', 'EN', '/blɑːst/', 'n.爆炸；一阵；v.爆炸；摧毁；抨击', 'The blast destroyed several buildings in the area.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (501, 1, 'bleed', 'EN', '/bliːd/', 'v.流血；出血；渗出；n.出血；放血', 'He started to bleed after cutting his finger.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (502, 1, 'blend', 'EN', '/blend/', 'v.混合；融合；调和；n.混合物；混合', 'Blend the milk and eggs together in a bowl.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (503, 1, 'blind', 'EN', '/blaɪnd/', 'adj.盲的；失明的；盲目的；v.使失明；蒙蔽', 'He was blind in one eye after the accident.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (504, 1, 'block', 'EN', '/blɒk/', 'n.块；街区；障碍物；v.阻挡；堵塞；封锁', 'A fallen tree blocked the road after the storm.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (505, 1, 'blood', 'EN', '/blʌd/', 'n.血；血液；血统；气质；脾气', 'He lost a lot of blood in the accident.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (506, 1, 'blow', 'EN', '/bləʊ/', 'v.吹；吹动；爆炸；n.打击；吹；殴打', 'The wind blew the leaves off the trees.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (507, 1, 'board', 'EN', '/bɔːd/', 'n.板；董事会；v.登上；寄宿；提供膳宿', 'She is on the board of directors of the company.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (508, 1, 'boast', 'EN', '/bəʊst/', 'v.吹嘘；夸耀；n.吹嘘；自夸；引以为傲的事物', 'He likes to boast about his expensive car.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (509, 1, 'bold', 'EN', '/bəʊld/', 'adj.大胆的；勇敢的；粗体的；鲁莽的', 'She made a bold decision to quit her job and travel.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (510, 1, 'bond', 'EN', '/bɒnd/', 'n.债券；纽带；v.结合；黏合；建立关系', 'There is a strong bond between the two friends.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (511, 1, 'boom', 'EN', '/buːm/', 'n.繁荣；热潮；v.繁荣；激增；轰鸣', 'The housing market is experiencing a boom right now.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (512, 1, 'boost', 'EN', '/buːst/', 'v.促进；提高；n.推动；增长；激励', 'We need to boost sales this quarter with a new marketing campaign.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (513, 1, 'border', 'EN', '/ˈbɔːdə(r)/', 'n.边界；边境；v.接壤；毗邻；接近', 'The two countries share a common border.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (514, 1, 'bore', 'EN', '/bɔː(r)/', 'v.使厌烦；钻孔；n.令人厌烦的人/事；孔', 'This movie is really boring, I almost fell asleep.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (515, 1, 'boring', 'EN', '/ˈbɔːrɪŋ/', 'adj.无聊的；令人厌烦的；乏味的', 'I hate doing boring homework on weekends.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (516, 1, 'boss', 'EN', '/bɒs/', 'n.老板；上司；v.指挥；发号施令；adj.主要的；首领的', 'My boss is very strict but fair.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (517, 1, 'bound', 'EN', '/baʊnd/', 'adj.一定的；有义务的；v.跳跃；限制；n.边界；跳跃', 'You are bound to succeed if you work hard.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (518, 1, 'boundary', 'EN', '/ˈbaʊndri/', 'n.边界；界限；分界线；范围', 'The river forms the boundary between the two countries.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (519, 1, 'bow', 'EN', '/baʊ/', 'v.鞠躬；点头；n.鞠躬；船头；弓；蝴蝶结', 'He bowed to the audience after his performance.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (520, 1, 'brain', 'EN', '/breɪn/', 'n.大脑；头脑；智力；v.猛击头部；打…的脑袋', 'She has a sharp brain and learns things quickly.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (521, 1, 'branch', 'EN', '/brɑːntʃ/', 'n.树枝；分支；部门；v.分支；分叉；扩大业务', 'The company has a branch office in Beijing.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (522, 1, 'brand', 'EN', '/brænd/', 'n.品牌；商标；v.打烙印；加污名于；铭刻', 'This is a well-known brand of shoes.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (523, 1, 'brave', 'EN', '/breɪv/', 'adj.勇敢的；无畏的；v.勇敢面对；n.勇士', 'She was brave enough to speak up against the unfair rule.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (524, 1, 'breadth', 'EN', '/bredθ/', 'n.宽度；广度；范围；幅度；宽容度', 'His knowledge has great breadth and depth.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (525, 1, 'break', 'EN', '/breɪk/', 'v.打破；破碎；违反；n.休息；破裂；中断', 'He broke his arm while playing football.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (526, 1, 'breath', 'EN', '/breθ/', 'n.呼吸；气息；一口气；微风', 'She took a deep breath before speaking.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (527, 1, 'breathe', 'EN', '/briːð/', 'v.呼吸；吸入；呼出；生存；低语', 'It\'s hard to breathe in the crowded room.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (528, 1, 'brief', 'EN', '/briːf/', 'adj.简短的；短暂的；v.简报；摘要；n.摘要；简报', 'Please give a brief introduction of yourself.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (529, 1, 'bright', 'EN', '/braɪt/', 'adj.明亮的；聪明的；鲜艳的；adv.明亮地；欢快地', 'She has bright eyes and a big smile.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (530, 1, 'brilliant', 'EN', '/ˈbrɪliənt/', 'adj.卓越的；杰出的；明亮的；灿烂的', 'He is a brilliant scientist who made many discoveries.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (531, 1, 'bring', 'EN', '/brɪŋ/', 'v.带来；拿来；导致；引起；使处于某种状态', 'Please bring your homework to class tomorrow.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (532, 1, 'broad', 'EN', '/brɔːd/', 'adj.宽阔的；广泛的；概括的；adv.宽阔地；完全地', 'The river is very broad at this point.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (533, 1, 'broadcast', 'EN', '/ˈbrɔːdkɑːst/', 'v.广播；播放；n.广播节目；adj.广播的', 'The news will be broadcast live on TV tonight.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (534, 1, 'browse', 'EN', '/braʊz/', 'v.浏览；随意看；n.浏览；吃草', 'I like to browse the internet in my free time.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (535, 1, 'brush', 'EN', '/brʌʃ/', 'n.刷子；画笔；v.刷；擦过；掠过；轻触', 'She brushed her teeth twice a day.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (536, 1, 'budget', 'EN', '/ˈbʌdʒɪt/', 'n.预算；v.编制预算；adj.预算的；低廉的', 'We need to stay within our monthly budget.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (537, 1, 'build', 'EN', '/bɪld/', 'v.建造；建设；建立；n.体型；构造；体格', 'They are building a new house in the countryside.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (538, 1, 'building', 'EN', '/ˈbɪldɪŋ/', 'n.建筑物；大楼；房屋；建筑', 'The office building is 20 stories high.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (539, 1, 'bulb', 'EN', '/bʌlb/', 'n.灯泡；球茎；球状物；v.膨胀；长出球茎', 'The light bulb in the room is broken.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (540, 1, 'bulk', 'EN', '/bʌlk/', 'n.主体；大部分；v.变得庞大；adj.大批的；大量的', 'The bulk of the work is done by the team leader.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (541, 1, 'bullet', 'EN', '/ˈbʊlɪt/', 'n.子弹；枪弹；v.快速移动；射出', 'The bullet hit the target right in the center.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (542, 1, 'bundle', 'EN', '/ˈbʌndl/', 'n.捆；束；包；v.捆扎；收集；匆忙离开', 'She tied the flowers into a bundle with string.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (543, 1, 'burden', 'EN', '/ˈbɜːdn/', 'n.负担；重担；v.使负担；加重压于；烦扰', 'She doesn\'t want to be a burden to her family.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (544, 1, 'burn', 'EN', '/bɜːn/', 'v.燃烧；烧毁；n.烧伤；灼伤；烙印', 'The fire burned the old house to the ground.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (545, 1, 'burst', 'EN', '/bɜːst/', 'v.爆发；破裂；突然出现；n.爆发；破裂；突发', 'She burst into tears when she heard the bad news.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (546, 1, 'bury', 'EN', '/ˈberi/', 'v.埋葬；掩埋；隐藏；埋头于', 'They buried their dog in the backyard.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (547, 1, 'business', 'EN', '/ˈbɪznəs/', 'n.商业；生意；业务；事务；职业', 'He started his own business after college.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (548, 1, 'busy', 'EN', '/ˈbɪzi/', 'adj.忙碌的；繁忙的；v.使忙于；adj.热闹的；占线的', 'I\'m very busy with work these days.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (549, 1, 'butterfly', 'EN', '/ˈbʌtəflaɪ/', 'n.蝴蝶；蝶泳；v.切开摊平', 'There are many colorful butterflies in the garden.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (550, 1, 'button', 'EN', '/ˈbʌtn/', 'n.按钮；纽扣；v.扣上纽扣；扣紧；按下按钮', 'Press the button to turn on the machine.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (551, 1, 'buy', 'EN', '/baɪ/', 'v.购买；买；收买；n.购买；买卖', 'She bought a new dress for the party.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (552, 1, 'bypass', 'EN', '/ˈbaɪpɑːs/', 'v.绕过；避开；n.旁路；旁道；支路', 'We took the bypass to avoid the traffic jam.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (553, 1, 'cabbage', 'EN', '/ˈkæbɪdʒ/', 'n.卷心菜；洋白菜；甘蓝；v.偷窃；顺手牵羊', 'We had cabbage soup for dinner last night.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (554, 1, 'calculate', 'EN', '/ˈkælkjuleɪt/', 'v.计算；核算；估计；推测；计划', 'You need to calculate the total cost of the project.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (555, 1, 'calendar', 'EN', '/ˈkælɪndə(r)/', 'n.日历；月历；日程表；v.把…列入日程；列入表中', 'Mark the important dates on your calendar.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (556, 1, 'call', 'EN', '/kɔːl/', 'v.呼叫；称呼；打电话；n.电话；呼叫；拜访', 'Please call me when you arrive at the station.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (557, 1, 'calm', 'EN', '/kɑːm/', 'adj.平静的；冷静的；v.使平静；镇定；n.平静；镇定', 'She tried to stay calm during the exam.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (558, 1, 'camera', 'EN', '/ˈkæmərə/', 'n.照相机；摄影机；摄像机；v.用照相机拍摄', 'He took a lot of photos with his new camera.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (559, 1, 'campaign', 'EN', '/kæmˈpeɪn/', 'n.运动；战役；v.参加运动；作战；竞选', 'The government launched a campaign against smoking.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (560, 1, 'campus', 'EN', '/ˈkæmpəs/', 'n.校园；校区；大学；学院', 'There are many students on the campus during the day.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (561, 1, 'cancel', 'EN', '/ˈkænsəl/', 'v.取消；撤销；删去；n.取消；撤销；删去', 'We had to cancel the picnic because of the rain.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (562, 1, 'cancer', 'EN', '/ˈkænsə(r)/', 'n.癌症；恶性肿瘤；弊端；毒瘤；巨蟹座', 'She was diagnosed with cancer last year.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (563, 1, 'candidate', 'EN', '/ˈkændɪdət/', 'n.候选人；申请人；应试者；求职者', 'There are three candidates for the job position.', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (564, 1, 'candle', 'EN', '/ˈkændl/', 'n.蜡烛；烛光；v.对着光检查；用光照检查', 'We lit candles during the power outage', 1, '2026-04-21 21:39:47', '2026-04-21 21:39:47');
INSERT INTO `word` VALUES (565, 3, '﻿accelerate', 'EN', '/əkˈseləreɪt/', '加速；促进', 'The new policy will accelerate economic growth.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (566, 3, 'accommodate', 'EN', '/əˈkɒmədeɪt/', '容纳；适应', 'The hotel can accommodate 500 guests.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (567, 3, 'accompany', 'EN', '/əˈkʌmpəni/', '陪伴；伴随', 'She accompanied her grandmother to the hospital.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (568, 3, 'accomplish', 'EN', '/əˈkʌmplɪʃ/', '完成；实现', 'We have accomplished all the annual goals.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (569, 3, 'account', 'EN', '/əˈkaʊnt/', '账户；解释', 'He gave a detailed account of the accident.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (570, 3, 'accumulate', 'EN', '/əˈkjuːmjəleɪt/', '积累；积聚', 'Debts began to accumulate rapidly.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (571, 3, 'accurate', 'EN', '/ˈækjərət/', '精确的；准确的', 'His report is accurate and reliable.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (572, 3, 'accuse', 'EN', '/əˈkjuːz/', '指责；控告', 'He was accused of stealing the documents.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (573, 3, 'adapt', 'EN', '/əˈdæpt/', '适应；改编', 'Animals must adapt to their environment.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (574, 3, 'adequate', 'EN', '/ˈædɪkwət/', '足够的；适当的', 'We don\'t have adequate time for the task.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (575, 3, 'adjust', 'EN', '/əˈdʒʌst/', '调整；校正', 'You need to adjust the camera settings.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (576, 3, 'adopt', 'EN', '/əˈdɒpt/', '采用；收养', 'The company adopted a new marketing strategy.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (577, 3, 'advance', 'EN', '/ədˈvɑːns/', '前进；进步', 'Technology has advanced rapidly in recent years.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (578, 3, 'advantage', 'EN', '/ədˈvɑːntɪdʒ/', '优势；有利条件', 'His experience gives him an advantage.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (579, 3, 'adventure', 'EN', '/ədˈventʃə/', '冒险；奇遇', 'She loves outdoor adventure activities.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (580, 3, 'advocate', 'EN', '/ˈædvəkeɪt/', '提倡；拥护', 'He advocates for environmental protection.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (581, 3, 'affect', 'EN', '/əˈfekt/', '影响；感染', 'Stress can affect your health negatively.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (582, 3, 'afford', 'EN', '/əˈfɔːd/', '买得起；承担得起', 'We can\'t afford to waste any more time.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (583, 3, 'aggressive', 'EN', '/əˈɡresɪv/', '侵略性的；积极的', 'He has an aggressive business style.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (584, 3, 'allocate', 'EN', '/ˈæləkeɪt/', '分配；拨出', 'The government allocated funds for education.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (585, 3, 'alter', 'EN', '/ˈɔːltə/', '改变；改动', 'We need to alter our plans slightly.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (586, 3, 'alternative', 'EN', '/ɔːlˈtɜːnətɪv/', '可供选择的；替代的', 'There is no alternative but to wait.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (587, 3, 'ambition', 'EN', '/æmˈbɪʃn/', '野心；抱负', 'Her ambition is to become a scientist.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (588, 3, 'analyze', 'EN', '/ˈænəlaɪz/', '分析；研究', 'We need to analyze the data carefully.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (589, 3, 'announce', 'EN', '/əˈnaʊns/', '宣布；宣告', 'They announced the results of the election.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (590, 3, 'anticipate', 'EN', '/ænˈtɪsɪpeɪt/', '预期；预料', 'We didn\'t anticipate such a large turnout.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (591, 3, 'anxiety', 'EN', '/æŋˈzaɪəti/', '焦虑；担忧', 'She felt a sense of anxiety before the exam.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (592, 3, 'apparent', 'EN', '/əˈpærənt/', '明显的；表面的', 'There is an apparent contradiction in his statement.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (593, 3, 'appeal', 'EN', '/əˈpiːl/', '呼吁；上诉', 'They appealed for more aid to the region.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (594, 3, 'appearance', 'EN', '/əˈpɪərəns/', '外观；出现', 'He changed his appearance completely.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (595, 3, 'applicable', 'EN', '/əˈplɪkəbl/', '适用的；合适的', 'The rule is applicable to all cases.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (596, 3, 'apply', 'EN', '/əˈplaɪ/', '申请；应用', 'She decided to apply for the scholarship.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (597, 3, 'appoint', 'EN', '/əˈpɔɪnt/', '任命；约定', 'They appointed a new manager for the project.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (598, 3, 'approach', 'EN', '/əˈprəʊtʃ/', '方法；接近', 'We need a new approach to solve the problem.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (599, 3, 'appropriate', 'EN', '/əˈprəʊpriət/', '适当的；合适的', 'Choose the appropriate tool for the job.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (600, 3, 'approve', 'EN', '/əˈpruːv/', '批准；赞成', 'The committee approved the proposal unanimously.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (601, 3, 'approximate', 'EN', '/əˈprɒksɪmət/', '近似的；大约的', 'The approximate cost is 1000 dollars.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (602, 3, 'arise', 'EN', '/əˈraɪz/', '出现；产生', 'Problems often arise during the process.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (603, 3, 'arrange', 'EN', '/əˈreɪndʒ/', '安排；布置', 'She arranged the meeting for next week.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (604, 3, 'arrest', 'EN', '/əˈrest/', '逮捕；阻止', 'The police arrested the suspect yesterday.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (605, 3, 'articulate', 'EN', '/ɑːˈtɪkjuleɪt/', '清晰表达；发音清晰', 'He is articulate and persuasive in his speech.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (606, 3, 'aspect', 'EN', '/ˈæspekt/', '方面；层面', 'We must consider every aspect of the plan.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (607, 3, 'assess', 'EN', '/əˈses/', '评估；评价', 'The teacher will assess our performance fairly.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (608, 3, 'assign', 'EN', '/əˈsaɪn/', '分配；指派', 'The boss assigned me to the new project.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (609, 3, 'assist', 'EN', '/əˈsɪst/', '帮助；协助', 'She assisted the professor with the research.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (610, 3, 'associate', 'EN', '/əˈsəʊsieɪt/', '联系；联想', 'People often associate red with danger.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (611, 3, 'assume', 'EN', '/əˈsjuːm/', '假定；认为', 'We can\'t assume the outcome before the test.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (612, 3, 'assure', 'EN', '/əˈʃʊə/', '保证；使确信', 'He assured us that the project would finish on time.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (613, 3, 'attach', 'EN', '/əˈtætʃ/', '附上；重视', 'Please attach the document to your email.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (614, 3, 'attain', 'EN', '/əˈteɪn/', '达到；获得', 'She attained her goals through hard work.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (615, 3, 'attempt', 'EN', '/əˈtempt/', '尝试；试图', 'He made an attempt to climb the mountain.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (616, 3, 'attend', 'EN', '/əˈtend/', '参加；出席', 'All students must attend the lecture.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (617, 3, 'attribute', 'EN', '/əˈtrɪbjuːt/', '把…归因于；属性', 'She attributes her success to hard work.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (618, 3, 'authority', 'EN', '/ɔːˈθɒrəti/', '权威；当局', 'You need permission from the relevant authority.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (619, 3, 'available', 'EN', '/əˈveɪləbl/', '可获得的；有空的', 'The product is available online only.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (620, 3, 'average', 'EN', '/ˈævərɪdʒ/', '平均的；普通的', 'His score is above average in the class.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (621, 3, 'avoid', 'EN', '/əˈvɔɪd/', '避免；避开', 'We should avoid making the same mistake again.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (622, 3, 'award', 'EN', '/əˈwɔːd/', '授予；奖品', 'She won an award for her outstanding performance.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (623, 3, 'aware', 'EN', '/əˈweə/', '意识到的；知道的', 'He is aware of the potential risks involved.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (624, 3, 'balance', 'EN', '/ˈbæləns/', '平衡；权衡', 'We need to balance work and life.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (625, 3, 'ban', 'EN', '/bæn/', '禁止；禁令', 'The city banned single-use plastic bags.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (626, 3, 'bare', 'EN', '/beə/', '赤裸的；仅仅的', 'The room was bare of any furniture.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (627, 3, 'barrier', 'EN', '/ˈbæriə/', '障碍；屏障', 'Language can be a barrier to communication.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (628, 3, 'base', 'EN', '/beɪs/', '基础；基地', 'The company has its base in Shanghai.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (629, 3, 'basic', 'EN', '/ˈbeɪsɪk/', '基本的；基础的', 'Everyone needs basic living conditions.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (630, 3, 'basis', 'EN', '/ˈbeɪsɪs/', '基础；根据', 'There is no basis for his claim.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (631, 3, 'bear', 'EN', '/beə/', '承受；忍受', 'I can\'t bear the pain any longer.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (632, 3, 'behalf', 'EN', '/bɪˈhɑːf/', '代表；利益', 'I\'m speaking on behalf of my team.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (633, 3, 'behave', 'EN', '/bɪˈheɪv/', '表现；举止', 'He behaved very professionally in the meeting.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (634, 3, 'belief', 'EN', '/bɪˈliːf/', '信念；信仰', 'Her belief in herself helped her succeed.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (635, 3, 'benefit', 'EN', '/ˈbenɪfɪt/', '益处；受益', 'Regular exercise benefits your physical health.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (636, 3, 'bias', 'EN', '/ˈbaɪəs/', '偏见；偏爱', 'We must avoid bias in scientific research.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (637, 3, 'bind', 'EN', '/baɪnd/', '捆绑；约束', 'The contract binds both parties to the agreement.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (638, 3, 'biology', 'EN', '/baɪˈɒlədʒi/', '生物学；生物', 'She majors in molecular biology.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (639, 3, 'blame', 'EN', '/bleɪm/', '责备；指责', 'Don\'t blame others for your own mistakes.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (640, 3, 'boost', 'EN', '/buːst/', '促进；提升', 'The new policy will boost the economy.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (641, 3, 'bound', 'EN', '/baʊnd/', '受约束的；必然的', 'We are bound by the terms of the contract.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (642, 3, 'brief', 'EN', '/briːf/', '简短的；摘要', 'Please give a brief introduction of yourself.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (643, 3, 'brilliant', 'EN', '/ˈbrɪliənt/', '杰出的；灿烂的', 'She has a brilliant mind for mathematics.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (644, 3, 'broad', 'EN', '/brɔːd/', '宽阔的；广泛的', 'We have a broad range of products to choose from.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (645, 3, 'budget', 'EN', '/ˈbʌdʒɪt/', '预算；安排', 'The project is within the budget limit.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (646, 3, 'build', 'EN', '/bɪld/', '建造；建立', 'They want to build a new community center.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (647, 3, 'burden', 'EN', '/ˈbɜːdn/', '负担；重任', 'He felt the heavy burden of responsibility.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (648, 3, 'burn', 'EN', '/bɜːn/', '燃烧；烧毁', 'The fire burned down the old building.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (649, 3, 'burst', 'EN', '/bɜːst/', '爆发；破裂', 'She burst into tears when she heard the news.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (650, 3, 'calculate', 'EN', '/ˈkælkjuleɪt/', '计算；估计', 'We need to calculate the total cost carefully.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (651, 3, 'campaign', 'EN', '/kæmˈpeɪn/', '运动；活动', 'They launched a campaign against pollution.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (652, 3, 'cancel', 'EN', '/ˈkænsl/', '取消；撤销', 'The flight was canceled due to bad weather.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (653, 3, 'candidate', 'EN', '/ˈkændɪdət/', '候选人；应试者', 'There are three candidates for the position.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (654, 3, 'capacity', 'EN', '/kəˈpæsəti/', '能力；容量', 'The hall has a seating capacity of 500.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (655, 3, 'capital', 'EN', '/ˈkæpɪtl/', '首都；资本', 'They invested large amounts of capital in the project.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (656, 3, 'capture', 'EN', '/ˈkæptʃə/', '捕获；占领', 'The army captured the city after a long siege.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (657, 3, 'career', 'EN', '/kəˈrɪə/', '职业；事业', 'She decided to pursue a career in medicine.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (658, 3, 'carry', 'EN', '/ˈkæri/', '携带；运送', 'The truck can carry up to 10 tons of goods.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (659, 3, 'case', 'EN', '/keɪs/', '情况；案例', 'Let\'s look at a specific case to understand.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (660, 3, 'cash', 'EN', '/kæʃ/', '现金；兑现', 'Do you accept cash or credit card?', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (661, 3, 'cause', 'EN', '/kɔːz/', '原因；导致', 'Smoking is the main cause of lung cancer.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (662, 3, 'cease', 'EN', '/siːs/', '停止；终止', 'The factory ceased production last year.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (663, 3, 'celebrate', 'EN', '/ˈselɪbreɪt/', '庆祝；庆贺', 'We will celebrate the victory with a party.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (664, 3, 'challenge', 'EN', '/ˈtʃælɪndʒ/', '挑战；质疑', 'She accepted the challenge with confidence.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (665, 3, 'change', 'EN', '/tʃeɪndʒ/', '改变；变化', 'Climate change is a global issue.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (666, 3, 'character', 'EN', '/ˈkærəktə/', '性格；角色', 'He is a man of strong character.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (667, 3, 'characteristic', 'EN', '/ˌkærəktəˈrɪstɪk/', '特征；特点', 'What are the main characteristics of this species?', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (668, 3, 'charge', 'EN', '/tʃɑːdʒ/', '收费；指控', 'They charged us 50 dollars for the service.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (669, 3, 'chart', 'EN', '/tʃɑːt/', '图表；绘制', 'The chart shows the sales trend over time.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (670, 3, 'chase', 'EN', '/tʃeɪs/', '追逐；追求', 'He chased his dream despite many difficulties.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (671, 3, 'cheat', 'EN', '/tʃiːt/', '欺骗；作弊', 'He was caught cheating in the exam.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (672, 3, 'check', 'EN', '/tʃek/', '检查；核对', 'Please check the details before submitting.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (673, 3, 'cheer', 'EN', '/tʃɪə/', '欢呼；鼓励', 'The crowd cheered when the team scored.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (674, 3, 'choose', 'EN', '/tʃuːz/', '选择；挑选', 'You can choose any topic for your paper.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (675, 3, 'circle', 'EN', '/ˈsɜːkl/', '圆圈；循环', 'She has a small circle of close friends.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (676, 3, 'cite', 'EN', '/saɪt/', '引用；引证', 'You must cite your sources in academic writing.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (677, 3, 'claim', 'EN', '/kleɪm/', '声称；索赔', 'He claimed that he was innocent.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (678, 3, 'clarify', 'EN', '/ˈklærəfaɪ/', '澄清；阐明', 'Can you clarify your point for us?', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (679, 3, 'classify', 'EN', '/ˈklæsɪfaɪ/', '分类；归类', 'We need to classify the data into different groups.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (680, 3, 'clear', 'EN', '/klɪə/', '清楚的；清除', 'Make sure the instructions are clear for everyone.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (681, 3, 'climb', 'EN', '/klaɪm/', '攀登；上升', 'They plan to climb the mountain next summer.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (682, 3, 'close', 'EN', '/kləʊz/', '关闭；接近', 'The shop will close at 9 PM today.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (683, 3, 'collect', 'EN', '/kəˈlekt/', '收集；采集', 'She collects stamps from all over the world.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (684, 3, 'combine', 'EN', '/kəmˈbaɪn/', '结合；组合', 'We need to combine theory with practice.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (685, 3, 'come', 'EN', '/kʌm/', '来；出现', 'When will the results come out?', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (686, 3, 'command', 'EN', '/kəˈmɑːnd/', '命令；指挥', 'The general commanded his troops to advance.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (687, 3, 'comment', 'EN', '/ˈkɒment/', '评论；意见', 'He made a negative comment about the plan.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (688, 3, 'commerce', 'EN', '/ˈkɒmɜːs/', '商业；贸易', 'International commerce has grown rapidly.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (689, 3, 'commit', 'EN', '/kəˈmɪt/', '犯；承诺', 'He committed a serious mistake in his work.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (690, 3, 'communicate', 'EN', '/kəˈmjuːnɪkeɪt/', '交流；沟通', 'Good communication is essential in a team.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (691, 3, 'community', 'EN', '/kəˈmjuːnəti/', '社区；团体', 'We live in a friendly community.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (692, 3, 'compare', 'EN', '/kəmˈpeə/', '比较；对比', 'You can compare the two products side by side.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (693, 3, 'compete', 'EN', '/kəmˈpiːt/', '竞争；比赛', 'They will compete against each other in the final.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (694, 3, 'complete', 'EN', '/kəmˈpliːt/', '完成；完整的', 'The project is now complete and ready for use.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (695, 3, 'complex', 'EN', '/ˈkɒmpleks/', '复杂的；综合体', 'The problem is too complex to solve quickly.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (696, 3, 'complicated', 'EN', '/ˈkɒmplɪkeɪtɪd/', '复杂的；难懂的', 'The situation is very complicated.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (697, 3, 'component', 'EN', '/kəmˈpəʊnənt/', '组成部分；组件', 'Each component must be tested before assembly.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (698, 3, 'compose', 'EN', '/kəmˈpəʊz/', '组成；创作', 'The committee is composed of five members.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (699, 3, 'comprehend', 'EN', '/ˌkɒmprɪˈhend/', '理解；领会', 'It\'s hard to comprehend the scale of the disaster.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (700, 3, 'comprehensive', 'EN', '/ˌkɒmprɪˈhensɪv/', '全面的；综合的', 'We need a comprehensive plan for the project.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (701, 3, 'compress', 'EN', '/kəmˈpres/', '压缩；压紧', 'We need to compress the data to save space.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (702, 3, 'comprise', 'EN', '/kəmˈpraɪz/', '包含；由…组成', 'The book comprises ten chapters.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (703, 3, 'compromise', 'EN', '/ˈkɒmprəmaɪz/', '妥协；折中', 'They reached a compromise after long negotiations.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (704, 3, 'compute', 'EN', '/kəmˈpjuːt/', '计算；估算', 'We can compute the result using this formula.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (705, 3, 'concentrate', 'EN', '/ˈkɒnsntreɪt/', '集中；专注', 'You need to concentrate on your studies.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (706, 3, 'concept', 'EN', '/ˈkɒnsept/', '概念；观念', 'The basic concept is easy to understand.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (707, 3, 'concern', 'EN', '/kənˈsɜːn/', '关心；担忧', 'Parents are concerned about their children\'s safety.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (708, 3, 'conclude', 'EN', '/kənˈkluːd/', '得出结论；结束', 'We can conclude that the experiment was successful.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (709, 3, 'condition', 'EN', '/kənˈdɪʃn/', '条件；状况', 'The car is in excellent condition.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (710, 3, 'conduct', 'EN', '/kənˈdʌkt/', '实施；引导', 'They will conduct a survey among students.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (711, 3, 'conference', 'EN', '/ˈkɒnfərəns/', '会议；讨论会', 'She will attend an international conference next month.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (712, 3, 'confidence', 'EN', '/ˈkɒnfɪdəns/', '信心；信任', 'He has full confidence in his ability to succeed.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (713, 3, 'confirm', 'EN', '/kənˈfɜːm/', '确认；证实', 'Please confirm your attendance at the meeting.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (714, 3, 'conflict', 'EN', '/ˈkɒnflɪkt/', '冲突；矛盾', 'There is a conflict between the two sides.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (715, 3, 'confuse', 'EN', '/kənˈfjuːz/', '使困惑；混淆', 'Don\'t confuse these two similar words.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (716, 3, 'congress', 'EN', '/ˈkɒŋɡres/', '国会；代表大会', 'The congress passed the new law.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (717, 3, 'connect', 'EN', '/kəˈnekt/', '连接；联系', 'The bridge connects the two cities.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (718, 3, 'consequence', 'EN', '/ˈkɒnsɪkwəns/', '结果；后果', 'You must face the consequences of your actions.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (719, 3, 'consider', 'EN', '/kənˈsɪdə/', '考虑；认为', 'We need to consider all possible options.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (720, 3, 'consist', 'EN', '/kənˈsɪst/', '由…组成；存在于', 'The team consists of ten players.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (721, 3, 'constant', 'EN', '/ˈkɒnstənt/', '持续的；恒定的', 'Change is the only constant in life.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (722, 3, 'constitute', 'EN', '/ˈkɒnstɪtjuːt/', '构成；组成', 'Twelve months constitute a year.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (723, 3, 'construct', 'EN', '/kənˈstrʌkt/', '建造；构造', 'They will construct a new bridge over the river.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (724, 3, 'consult', 'EN', '/kənˈsʌlt/', '咨询；请教', 'You should consult a doctor about your symptoms.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (725, 3, 'consume', 'EN', '/kənˈsjuːm/', '消耗；消费', 'The car consumes a lot of fuel.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (726, 3, 'contact', 'EN', '/ˈkɒntækt/', '联系；接触', 'Please contact us if you have any questions.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (727, 3, 'contain', 'EN', '/kənˈteɪn/', '包含；容纳', 'The box contains many small items.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (728, 3, 'continue', 'EN', '/kənˈtɪnjuː/', '继续；持续', 'The meeting will continue after lunch.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (729, 3, 'contract', 'EN', '/ˈkɒntrækt/', '合同；收缩', 'They signed a contract with the company.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (730, 3, 'contradict', 'EN', '/ˌkɒntrəˈdɪkt/', '反驳；与…矛盾', 'His actions contradict his words.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (731, 3, 'contribute', 'EN', '/kənˈtrɪbjuːt/', '贡献；促成', 'Everyone can contribute to environmental protection.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (732, 3, 'control', 'EN', '/kənˈtrəʊl/', '控制；管理', 'She has no control over the situation.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (733, 3, 'convenient', 'EN', '/kənˈviːniənt/', '方便的；便利的', 'The new store is very convenient for us.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (734, 3, 'converse', 'EN', '/kənˈvɜːs/', '交谈；相反的', 'They conversed about their plans for the future.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (735, 3, 'convince', 'EN', '/kənˈvɪns/', '说服；使确信', 'She convinced him to change his mind.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (736, 3, 'cooperate', 'EN', '/kəʊˈɒpəreɪt/', '合作；协作', 'We need to cooperate with other teams.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (737, 3, 'cope', 'EN', '/kəʊp/', '处理；应付', 'She is learning to cope with stress better.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (738, 3, 'correct', 'EN', '/kəˈrekt/', '正确的；纠正', 'Please correct any mistakes in the report.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (739, 3, 'correspond', 'EN', '/ˌkɒrɪˈspɒnd/', '符合；通信', 'The results correspond with our expectations.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (740, 3, 'cost', 'EN', '/kɒst/', '花费；代价', 'The project cost more than expected.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (741, 3, 'count', 'EN', '/kaʊnt/', '数；计算', 'Every vote counts in the election.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (742, 3, 'couple', 'EN', '/ˈkʌpl/', '一对；夫妇', 'A couple of friends came to visit me.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (743, 3, 'course', 'EN', '/kɔːs/', '课程；过程', 'She is taking a course in computer science.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (744, 3, 'cover', 'EN', '/ˈkʌvə/', '覆盖；包括', 'The report covers all aspects of the project.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (745, 3, 'create', 'EN', '/kriːˈeɪt/', '创造；创作', 'They want to create a new work of art.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (746, 3, 'credit', 'EN', '/ˈkredɪt/', '信用；赞扬', 'She deserves credit for her hard work.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (747, 3, 'crisis', 'EN', '/ˈkraɪsɪs/', '危机；紧要关头', 'The company is facing a financial crisis.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (748, 3, 'critical', 'EN', '/ˈkrɪtɪkl/', '关键的；批评的', 'It is critical that we meet the deadline.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (749, 3, 'cross', 'EN', '/krɒs/', '穿过；交叉', 'We crossed the river by boat.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (750, 3, 'crowd', 'EN', '/kraʊd/', '人群；挤满', 'A large crowd gathered in the square.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (751, 3, 'culture', 'EN', '/ˈkʌltʃə/', '文化；教养', 'We should respect different cultures.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (752, 3, 'curious', 'EN', '/ˈkjʊəriəs/', '好奇的；求知的', 'She is curious about everything around her.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (753, 3, 'current', 'EN', '/ˈkʌrənt/', '当前的；水流', 'The current situation is very serious.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (754, 3, 'custom', 'EN', '/ˈkʌstəm/', '习俗；习惯', 'It is a local custom to give gifts at weddings.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (755, 3, 'cycle', 'EN', '/ˈsaɪkl/', '循环；周期', 'The seasons follow a natural cycle.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (756, 3, 'damage', 'EN', '/ˈdæmɪdʒ/', '损害；损坏', 'The storm caused a lot of damage.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (757, 3, 'danger', 'EN', '/ˈdeɪndʒə/', '危险；风险', 'There is a danger of falling rocks here.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (758, 3, 'data', 'EN', '/ˈdeɪtə/', '数据；资料', 'We need to collect more data for our research.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (759, 3, 'deal', 'EN', '/diːl/', '处理；交易', 'She knows how to deal with difficult people.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (760, 3, 'debate', 'EN', '/dɪˈbeɪt/', '辩论；争论', 'They had a heated debate about the issue.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (761, 3, 'decide', 'EN', '/dɪˈsaɪd/', '决定；判定', 'We need to decide on a plan soon.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (762, 3, 'declare', 'EN', '/dɪˈkleə/', '宣布；声明', 'He declared his intention to run for office.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (763, 3, 'decrease', 'EN', '/dɪˈkriːs/', '减少；降低', 'We need to decrease our expenses.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (764, 3, 'dedicate', 'EN', '/ˈdedɪkeɪt/', '致力于；奉献', 'She dedicated her life to helping others.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (765, 3, 'defend', 'EN', '/dɪˈfend/', '防御；辩护', 'He defended his position in the argument.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (766, 3, 'define', 'EN', '/dɪˈfaɪn/', '定义；阐明', 'We need to define the problem clearly.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (767, 3, 'degree', 'EN', '/dɪˈɡriː/', '程度；学位', 'She has a master\'s degree in education.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (768, 3, 'delay', 'EN', '/dɪˈleɪ/', '延迟；耽搁', 'The flight was delayed by bad weather.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (769, 3, 'deliver', 'EN', '/dɪˈlɪvə/', '递送；发表', 'The mail is delivered every morning.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (770, 3, 'demand', 'EN', '/dɪˈmɑːnd/', '要求；需求', 'There is a high demand for skilled workers.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (771, 3, 'demonstrate', 'EN', '/ˈdemənstreɪt/', '证明；展示', 'The experiment demonstrates the principle clearly.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (772, 3, 'deny', 'EN', '/dɪˈnaɪ/', '否认；拒绝', 'He denied any involvement in the scandal.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (773, 3, 'depend', 'EN', '/dɪˈpend/', '依赖；取决于', 'Success depends on hard work and luck.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (774, 3, 'depict', 'EN', '/dɪˈpɪkt/', '描绘；描述', 'The painting depicts a beautiful landscape.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (775, 3, 'deploy', 'EN', '/dɪˈplɔɪ/', '部署；配置', 'The army will deploy more troops to the area.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (776, 3, 'depress', 'EN', '/dɪˈpres/', '使沮丧；压低', 'She felt depressed after the failure.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (777, 3, 'derive', 'EN', '/dɪˈraɪv/', '获得；起源于', 'Many words derive from Latin.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (778, 3, 'describe', 'EN', '/dɪˈskraɪb/', '描述；形容', 'Can you describe the suspect to the police?', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (779, 3, 'desert', 'EN', '/ˈdezət/', '沙漠；抛弃', 'He was deserted by his friends when he needed help.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (780, 3, 'deserve', 'EN', '/dɪˈzɜːv/', '应得；值得', 'She deserves the award for her excellent work.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (781, 3, 'design', 'EN', '/dɪˈzaɪn/', '设计；计划', 'The new building has a modern design.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (782, 3, 'desire', 'EN', '/dɪˈzaɪə/', '渴望；愿望', 'He has a strong desire to succeed.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (783, 3, 'detail', 'EN', '/ˈdiːteɪl/', '细节；详述', 'We need to pay attention to every detail.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (784, 3, 'detect', 'EN', '/dɪˈtekt/', '发现；探测', 'The device can detect small changes in temperature.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (785, 3, 'determine', 'EN', '/dɪˈtɜːmɪn/', '确定；决定', 'The test results will determine our next steps.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (786, 3, 'develop', 'EN', '/dɪˈveləp/', '发展；开发', 'The company is developing a new product.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (787, 3, 'devote', 'EN', '/dɪˈvəʊt/', '致力于；奉献', 'She devotes most of her time to her family.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (788, 3, 'diagram', 'EN', '/ˈdaɪəɡræm/', '图表；示意图', 'The diagram shows the process step by step.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (789, 3, 'differ', 'EN', '/ˈdɪfə/', '不同；有差异', 'Their opinions differ on this matter.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (790, 3, 'difficult', 'EN', '/ˈdɪfɪkəlt/', '困难的；难懂的', 'It is difficult to solve this problem alone.', 1, '2026-04-21 21:40:11', '2026-04-21 21:40:11');
INSERT INTO `word` VALUES (791, 17, 'abundant', 'EN', NULL, '/əˈbʌndənt/ adj. 丰富的；大量的 There is abundant evidence to support his theory.（有充分的证据支持他的理论。）', NULL, 1, '2026-04-23 14:13:13', '2026-04-23 14:13:13');
INSERT INTO `word` VALUES (792, 17, 'achieve', 'EN', NULL, '/əˈtʃiːv/ v. 实现；达到；完成 She worked hard and finally achieved her dream.（她努力工作，最终实现了自己的梦想。）', NULL, 1, '2026-04-23 14:13:13', '2026-04-23 14:13:13');
INSERT INTO `word` VALUES (793, 17, 'benefit', 'EN', NULL, '/ˈbenɪfɪt/ n. 益处；好处 v. 有益于；受益 Regular exercise is of great benefit to our health.（规律运动对我们的健康大有裨益。）', NULL, 1, '2026-04-23 14:13:13', '2026-04-23 14:13:13');
INSERT INTO `word` VALUES (794, 17, 'challenge', 'EN', NULL, '/ˈtʃælɪndʒ/ n. 挑战；难题 v. 向……挑战 Facing difficulties bravely is the best way to meet a challenge.（勇敢面对困难是迎接挑战的最佳方式。）', NULL, 1, '2026-04-23 14:13:13', '2026-04-23 14:13:13');
INSERT INTO `word` VALUES (795, 17, 'cooperate', 'EN', NULL, '/kəʊˈɒpəreɪt/ v. 合作；协作 We need to cooperate with each other to finish this task on time.（我们需要相互合作，按时完成这项任务。）', NULL, 1, '2026-04-23 14:13:13', '2026-04-23 14:13:13');
INSERT INTO `word` VALUES (796, 17, 'determine', 'EN', NULL, '/dɪˈtɜːmɪn/ v. 决定；确定；决心 He determined to study abroad after graduating from high school.（他决定高中毕业后出国留学。）', NULL, 1, '2026-04-23 14:13:13', '2026-04-23 14:13:13');
INSERT INTO `word` VALUES (797, 17, 'efficient', 'EN', NULL, '/ɪˈfɪʃnt/ adj. 高效的；有能力的 This new machine is more efficient than the old one.（这台新机器比旧机器更高效。）', NULL, 1, '2026-04-23 14:13:13', '2026-04-23 14:13:13');
INSERT INTO `word` VALUES (798, 18, 'hello	/həˈləʊ/	你好	Hello', 'EN', NULL, 'nice to meet you!', NULL, 1, '2026-04-25 10:54:49', '2026-04-25 10:54:49');
INSERT INTO `word` VALUES (799, 18, 'world', 'EN', NULL, '/wɜːld/	世界	Welcome to the world!', NULL, 1, '2026-04-25 10:54:49', '2026-04-25 10:54:49');
INSERT INTO `word` VALUES (800, 18, 'computer', 'EN', NULL, '/kəmˈpjuːtər/计算机	I use computer every day.', NULL, 1, '2026-04-25 10:54:49', '2026-04-25 10:54:49');
INSERT INTO `word` VALUES (801, 18, 'english', 'EN', NULL, '/ˈɪŋɡlɪʃ/英语	I am learning English.', NULL, 1, '2026-04-25 10:54:49', '2026-04-25 10:54:49');
INSERT INTO `word` VALUES (802, 18, 'study', 'EN', NULL, '/ˈstʌdi/学习	Study makes me happy.', NULL, 1, '2026-04-25 10:54:49', '2026-04-25 10:54:49');
INSERT INTO `word` VALUES (803, 1, 'hello', 'EN', '/həˈləʊ/', '你好', 'Hello, nice to meet you!', 1, '2026-04-25 10:59:12', '2026-04-25 10:59:12');
INSERT INTO `word` VALUES (804, 1, 'world', 'EN', '/wɜːld/', '世界', 'Welcome to the world!', 1, '2026-04-25 10:59:12', '2026-04-25 10:59:12');
INSERT INTO `word` VALUES (805, 1, 'computer', 'EN', '/kəmˈpjuːtər/计算机', 'I use computer every day.', NULL, 1, '2026-04-25 10:59:12', '2026-04-25 10:59:12');
INSERT INTO `word` VALUES (806, 1, 'english', 'EN', '/ˈɪŋɡlɪʃ/英语', 'I am learning English.', NULL, 1, '2026-04-25 10:59:12', '2026-04-25 10:59:12');
INSERT INTO `word` VALUES (807, 1, 'study', 'EN', '/ˈstʌdi/学习', 'Study makes me happy.', NULL, 1, '2026-04-25 10:59:12', '2026-04-25 10:59:12');
INSERT INTO `word` VALUES (808, 19, 'hello	/həˈləʊ/	你好	Hello', 'EN', NULL, 'nice to meet you!', NULL, 1, '2026-04-25 11:55:14', '2026-04-25 11:55:14');
INSERT INTO `word` VALUES (809, 19, 'world', 'EN', NULL, '/wɜːld/	世界	Welcome to the world!', NULL, 1, '2026-04-25 11:55:14', '2026-04-25 11:55:14');
INSERT INTO `word` VALUES (810, 19, 'computer', 'EN', NULL, '/kəmˈpjuːtər/计算机	I use computer every day.', NULL, 1, '2026-04-25 11:55:14', '2026-04-25 11:55:14');
INSERT INTO `word` VALUES (811, 19, 'english', 'EN', NULL, '/ˈɪŋɡlɪʃ/英语	I am learning English.', NULL, 1, '2026-04-25 11:55:14', '2026-04-25 11:55:14');
INSERT INTO `word` VALUES (812, 19, 'study', 'EN', NULL, '/ˈstʌdi/学习	Study makes me happy.', NULL, 1, '2026-04-25 11:55:14', '2026-04-25 11:55:14');
INSERT INTO `word` VALUES (813, 20, 'hello', 'EN', '/həˈləʊ/', '你好', 'Hello, nice to meet you!', 1, '2026-04-25 11:58:17', '2026-04-25 11:58:17');
INSERT INTO `word` VALUES (814, 20, 'world', 'EN', '/wɜːld/', '世界', 'Welcome to the world!', 1, '2026-04-25 11:58:17', '2026-04-25 11:58:17');
INSERT INTO `word` VALUES (815, 20, 'computer', 'EN', '/kəmˈpjuːtər/', '计算机', 'I use computer every day.', 1, '2026-04-25 11:58:17', '2026-04-25 11:58:17');
INSERT INTO `word` VALUES (816, 20, 'english', 'EN', '/ˈɪŋɡlɪʃ/英语', 'I am learning English.', NULL, 1, '2026-04-25 11:58:17', '2026-04-25 11:58:17');
INSERT INTO `word` VALUES (817, 20, 'study', 'EN', '/ˈstʌdi/学习', 'Study makes me happy.', NULL, 1, '2026-04-25 11:58:17', '2026-04-25 11:58:17');
INSERT INTO `word` VALUES (818, 23, 'Hallo', 'DE', '[haˈloː]', '你好', 'Hallo, wie geht es dir?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (819, 23, 'Guten Tag', 'DE', '[ˈɡuːtn̩ ˈtaːk]', '日安/你好', 'Guten Tag, mein Name ist Hans.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (820, 23, 'Guten Morgen', 'DE', '[ˈɡuːtn̩ ˈmɔʁɡn̩]', '早上好', 'Guten Morgen! Hast du gut geschlafen?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (821, 23, 'Guten Abend', 'DE', '[ˈɡuːtn̩ ˈʔaːbn̩t]', '晚上好', 'Guten Abend, meine Damen und Herren.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (822, 23, 'Auf Wiedersehen', 'DE', '[aʊf ˈviːdɐzeːən]', '再见', 'Auf Wiedersehen und bis bald!', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (823, 23, 'Tschüss', 'DE', '[ˈtʃʏs]', '再见 (非正式)', 'Tschüss, bis morgen!', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (824, 23, 'Danke', 'DE', '[ˈdaŋkə]', '谢谢', 'Vielen Dank für Ihre Hilfe.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (825, 23, 'Bitte', 'DE', '[ˈbɪtə]', '请/不客气', 'Einmal Kaffee, bitte.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (826, 23, 'Ja', 'DE', '[jaː]', '是', 'Ja, das ist richtig.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (827, 23, 'Nein', 'DE', '[naɪn]', '不/不是', 'Nein, danke, ich möchte nichts.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (828, 23, 'Entschuldigung', 'DE', '[ɛntˈʃʊldɪɡʊŋ]', '对不起/打扰一下', 'Entschuldigung, wo ist die Toilette?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (829, 23, 'Wie geht es Ihnen?', 'DE', '[viː ˈɡeːt ɛs ˈiːnən]', '您好吗？', 'Wie geht es Ihnen heute?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (830, 23, 'Mir geht es gut.', 'DE', '[miːɐ̯ ɡeːt ɛs ɡuːt]', '我很好。', 'Mir geht es gut, danke.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (831, 23, 'Ich heiße...', 'DE', '[ɪç ˈhaɪ̯sə]', '我叫……', 'Ich heiße Thomas.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (832, 23, 'Und du?', 'DE', '[ʊnt duː]', '你呢？', 'Ich komme aus China. Und du?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (833, 23, 'Ich verstehe nicht.', 'DE', '[ɪç fɛɐ̯ˈʃteːə nɪçt]', '我不明白。', 'Bitte sprechen Sie langsamer, ich verstehe nicht.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (834, 23, 'Sprechen Sie Englisch?', 'DE', '[ˈʃpʁɛçn̩ ziː ˈɛŋlɪʃ]', '您说英语吗？', 'Sprechen Sie Englisch?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (835, 23, 'Ich lerne Deutsch.', 'DE', '[ɪç ˈlɛʁnə dɔʏtʃ]', '我在学德语。', 'Ich lerne seit drei Monaten Deutsch.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (836, 23, 'Eins', 'DE', '[ains]', '一', 'Das ist die Nummer eins.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (837, 23, 'Zwei', 'DE', '[tsvaɪ̯]', '二', 'Ich habe zwei Brüder.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (838, 23, 'Drei', 'DE', '[dʁaɪ̯]', '三', 'Es ist drei Uhr.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (839, 23, 'Vier', 'DE', '[fiːɐ̯]', '四', 'Das Auto hat vier Reifen.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (840, 23, 'Fünf', 'DE', '[fʏnf]', '五', 'Meine Hausnummer ist fünf.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (841, 23, 'Sechs', 'DE', '[zɛks]', '六', 'Es gibt sechs Äpfel.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (842, 23, 'Sieben', 'DE', '[ˈziːbn̩]', '七', 'Die Woche hat sieben Tage.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (843, 23, 'Acht', 'DE', '[axt]', '八', 'Meine Telefonnummer endet auf acht.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (844, 23, 'Neun', 'DE', '[nɔʏn]', '九', 'Es ist neun Uhr morgens.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (845, 23, 'Zehn', 'DE', '[tsɛn]', '十', 'Zehn Euro bitte.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (846, 23, 'Hundert', 'DE', '[ˈhʊndɐt]', '百', 'Das kostet hundert Euro.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (847, 23, 'Tausend', 'DE', '[ˈtaʊzn̩t]', '千', 'Ein tausend Dank.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (848, 23, 'Der Vater', 'DE', '[deːɐ̯ ˈfaːtɐ]', '父亲', 'Mein Vater ist Ingenieur.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (849, 23, 'Die Mutter', 'DE', '[diː ˈmʊtɐ]', '母亲', 'Meine Mutter kocht sehr gut.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (850, 23, 'Die Eltern', 'DE', '[diː ˈɛltɐn]', '父母', 'Meine Eltern wohnen in Berlin.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (851, 23, 'Der Sohn', 'DE', '[deːɐ̯ ˈzoːn]', '儿子', 'Unser Sohn geht zur Schule.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (852, 23, 'Die Tochter', 'DE', '[diː ˈtɔxtɐ]', '女儿', 'Unsere Tochter ist noch klein.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (853, 23, 'Das Kind', 'DE', '[das ˈkɪnt]', '孩子', 'Das Kind spielt im Garten.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (854, 23, 'Der Bruder', 'DE', '[deːɐ̯ ˈbʁuːdɐ]', '兄弟', 'Mein Bruder studiert Medizin.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (855, 23, 'Die Schwester', 'DE', '[diː ˈʃvɛstɐ]', '姐妹', 'Meine Schwester arbeitet in einer Bank.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (856, 23, 'Der Freund', 'DE', '[deːɐ̯ ˈfʁɔʏnt]', '男朋友/男性朋友', 'Mein Freund kommt aus Spanien.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (857, 23, 'Die Freundin', 'DE', '[diː ˈfʁɔʏndɪn]', '女朋友/女性朋友', 'Meine Freundin und ich gehen ins Kino.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (858, 23, 'Die Familie', 'DE', '[diː faˈmiːli̯ə]', '家庭', 'Meine Familie ist sehr groß.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (859, 23, 'Der Mann', 'DE', '[deːɐ̯ ˈman]', '男人/丈夫', 'Der Mann liest eine Zeitung.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (860, 23, 'Die Frau', 'DE', '[diː ˈfʁaʊ̯]', '女人/妻子', 'Die Frau kauft Blumen.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (861, 23, 'Das Baby', 'DE', '[das ˈbeːbi]', '婴儿', 'Das Baby schläft.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (862, 23, 'Der Opa', 'DE', '[deːɐ̯ ˈoːpa]', '爷爷/外公', 'Mein Opa erzählt Geschichten.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (863, 23, 'Die Oma', 'DE', '[diː ˈoːma]', '奶奶/外婆', 'Meine Oma backt Kuchen.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (864, 23, 'Heute', 'DE', '[ˈhɔʏtə]', '今天', 'Heute ist ein schöner Tag.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (865, 23, 'Morgen', 'DE', '[ˈmɔʁɡn̩]', '明天/早晨', 'Wir fahren morgen in den Urlaub.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (866, 23, 'Gestern', 'DE', '[ˈɡɛstɐn]', '昨天', 'Gestern war ich krank.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (867, 23, 'Jetzt', 'DE', '[jeːtst]', '现在', 'Wir haben jetzt Pause.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (868, 23, 'Später', 'DE', '[ˈʃpɛːtɐ]', '稍后/晚些', 'Ich rufe dich später an.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (869, 23, 'Die Zeit', 'DE', '[diː ˈtsaɪ̯t]', '时间', 'Wir haben keine Zeit.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (870, 23, 'Die Uhr', 'DE', '[diː ˈuːɐ̯]', '钟表/点钟', 'Wie spät ist es? Es ist zwölf Uhr.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (871, 23, 'Die Stunde', 'DE', '[diː ˈʃtʊndə]', '小时', 'Der Film dauert zwei Stunden.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (872, 23, 'Der Tag', 'DE', '[deːɐ̯ ˈtaːk]', '天/日', 'Tag für Tag.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (873, 23, 'Die Woche', 'DE', '[diː ˈvɔxə]', '周/星期', 'Eine Woche hat sieben Tage.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (874, 23, 'Der Monat', 'DE', '[deːɐ̯ ˈmoːnat]', '月/月份', 'Der nächste Monat ist der Juni.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (875, 23, 'Das Jahr', 'DE', '[das jaːɐ̯]', '年', 'Nächstes Jahr wird alles besser.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (876, 23, 'Montag', 'DE', '[ˈmoːntaːk]', '星期一', 'Am Montag habe ich viel zu tun.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (877, 23, 'Dienstag', 'DE', '[ˈdiːnstaːk]', '星期二', 'Dienstag ist der zweite Tag der Woche.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (878, 23, 'Mittwoch', 'DE', '[ˈmɪtvɔx]', '星期三', 'Heute ist Mittwoch.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (879, 23, 'Donnerstag', 'DE', '[ˈdɔnɐstaːk]', '星期四', 'Donnerstag ist fast Wochenende.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (880, 23, 'Freitag', 'DE', '[ˈfʁaɪ̯taːk]', '星期五', 'Endlich ist Freitag!', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (881, 23, 'Samstag', 'DE', '[ˈzamstaːk]', '星期六', 'Am Samstag gehen wir einkaufen.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (882, 23, 'Sonntag', 'DE', '[ˈzɔntaːk]', '星期日', 'Der Sonntag ist ein Ruhetag.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (883, 23, 'Das Wasser', 'DE', '[das ˈvasɐ]', '水', 'Möchten Sie ein Glas Wasser?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (884, 23, 'Das Brot', 'DE', '[das ˈbʁoːt]', '面包', 'Das Brot schmeckt sehr gut.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (885, 23, 'Der Kaffee', 'DE', '[deːɐ̯ ˈkafe]', '咖啡', 'Trinken Sie Kaffee oder Tee?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (886, 23, 'Die Milch', 'DE', '[diː ˈmɪlç]', '牛奶', 'Die Milch ist kalt.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (887, 23, 'Der Tee', 'DE', '[deːɐ̯ ˈteː]', '茶', 'Eine Tasse Tee, bitte.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (888, 23, 'Das Bier', 'DE', '[das ˈbiːɐ̯]', '啤酒', 'Prost! Ein Bier bitte.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (889, 23, 'Der Wein', 'DE', '[deːɐ̯ ˈvaɪ̯n]', '葡萄酒', 'Der Wein ist sehr teuer.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (890, 23, 'Das Essen', 'DE', '[das ˈɛsn̩]', '食物/吃饭', 'Das Essen ist fertig.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (891, 23, 'Das Frühstück', 'DE', '[das ˈfʁʏhstʏk]', '早餐', 'Das Frühstück ist das Wichtigste am Tag.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (892, 23, 'Das Mittagessen', 'DE', '[das ˈmɪtaːkˌʔɛsn̩]', '午餐', 'Wir treffen uns zum Mittagessen.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (893, 23, 'Das Abendessen', 'DE', '[das ˈaːbn̩tˌʔɛsn̩]', '晚餐', 'Das Abendessen gibt es um 18 Uhr.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (894, 23, 'Der Apfel', 'DE', '[deːɐ̯ ˈapfl̩]', '苹果', 'Ein Apfel am Tag hält den Arzt fern.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (895, 23, 'Die Banane', 'DE', '[diː baˈnaːnə]', '香蕉', 'Die Banane ist gelb.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (896, 23, 'Das Fleisch', 'DE', '[das ˈflaɪ̯ʃ]', '肉', 'Ich esse kein Fleisch.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (897, 23, 'Der Fisch', 'DE', '[deːɐ̯ ˈfɪʃ]', '鱼', 'Der Fisch kommt aus dem Meer.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (898, 23, 'Der Käse', 'DE', '[deːɐ̯ ˈkɛːzə]', '奶酪', 'Möchtest du Käse auf dem Brot?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (899, 23, 'Die Kartoffel', 'DE', '[diː kaɐ̯ˈtɔfl̩]', '土豆', 'Kartoffeln sind sehr gesund.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (900, 23, 'Der Reis', 'DE', '[deːɐ̯ ˈʁaɪ̯s]', '米饭', 'Der Reis ist noch heiß.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (901, 23, 'Das Haus', 'DE', '[das ˈhaʊ̯s]', '房子', 'Das Haus ist alt aber schön.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (902, 23, 'Die Wohnung', 'DE', '[diː ˈvoːnʊŋ]', '公寓', 'Die Wohnung ist sehr hell.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (903, 23, 'Das Zimmer', 'DE', '[das ˈtsɪmɐ]', '房间', 'Mein Zimmer ist klein.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (904, 23, 'Die Küche', 'DE', '[diː ˈkʏçə]', '厨房', 'Die Küche ist modern eingerichtet.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (905, 23, 'Das Bad', 'DE', '[das ˈbaːt]', '浴室/卫生间', 'Das Bad ist im ersten Stock.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (906, 23, 'Die Tür', 'DE', '[diː ˈtyːɐ̯]', '门', 'Mach bitte die Tür zu.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (907, 23, 'Das Fenster', 'DE', '[das ˈfɛnstɐ]', '窗户', 'Das Fenster ist offen.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (908, 23, 'Der Tisch', 'DE', '[deːɐ̯ ˈtɪʃ]', '桌子', 'Der Tisch steht in der Mitte.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (909, 23, 'Der Stuhl', 'DE', '[deːɐ̯ ˈʃtuːl]', '椅子', 'Setz dich auf den Stuhl.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (910, 23, 'Das Bett', 'DE', '[das ˈbɛt]', '床', 'Das Bett ist sehr bequem.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (911, 23, 'Der Schlüssel', 'DE', '[deːɐ̯ ˈʃlʏsl̩]', '钥匙', 'Wo ist der Schlüssel?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (912, 23, 'Die Stadt', 'DE', '[diː ˈʃtat]', '城市', 'Die Stadt ist sehr laut.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (913, 23, 'Das Land', 'DE', '[das ˈlant]', '国家/乡村', 'Wir fahren aufs Land.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (914, 23, 'Die Straße', 'DE', '[diː ˈʃtʁaːsə]', '街道', 'Die Straße ist gesperrt.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (915, 23, 'Der Platz', 'DE', '[deːɐ̯ ˈplats]', '广场', 'Der Marktplatz ist sehr schön.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (916, 23, 'Die Schule', 'DE', '[diː ˈʃuːlə]', '学校', 'Die Kinder gehen in die Schule.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (917, 23, 'Die Universität', 'DE', '[diː univɛʁziˈtɛːt]', '大学', 'Er studiert an der Universität.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (918, 23, 'Die Arbeit', 'DE', '[diː ˈaʁbaɪ̯t]', '工作', 'Die Arbeit macht Spaß.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (919, 23, 'Das Büro', 'DE', '[das bʏˈʁoː]', '办公室', 'Mein Büro ist im dritten Stock.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (920, 23, 'Der Bahnhof', 'DE', '[deːɐ̯ ˈbaːnhoːf]', '火车站', 'Der Zug fährt vom Bahnhof ab.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (921, 23, 'Der Flughafen', 'DE', '[deːɐ̯ ˈfluːkhaːfn̩]', '机场', 'Wir treffen uns am Flughafen.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (922, 23, 'Das Hotel', 'DE', '[das hoˈtɛl]', '酒店', 'Das Hotel liegt am Meer.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (923, 23, 'Das Restaurant', 'DE', '[das ʁɛstoˈʁɑ̃ː]', '餐厅', 'Das Restaurant ist zu teuer.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (924, 23, 'Der Supermarkt', 'DE', '[deːɐ̯ ˈzuːpɐmaʁkt]', '超市', 'Im Supermarkt gibt es alles.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (925, 23, 'Das Buch', 'DE', '[das ˈbuːx]', '书', 'Das Buch ist sehr interessant.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (926, 23, 'Der Stift', 'DE', '[deːɐ̯ ˈʃtɪft]', '笔', 'Der Stift schreibt nicht mehr.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (927, 23, 'Das Papier', 'DE', '[das paˈpiːɐ̯]', '纸', 'Gib mir bitte ein Blatt Papier.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (928, 23, 'Der Computer', 'DE', '[deːɐ̯ kɔmˈpjuːtɐ]', '电脑', 'Mein Computer ist kaputt.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (929, 23, 'Das Handy', 'DE', '[das ˈhɛndi]', '手机', 'Handys sind im Kino verboten.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (930, 23, 'Das Auto', 'DE', '[das ˈaʊ̯to]', '汽车', 'Mein Auto ist rot.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (931, 23, 'Der Bus', 'DE', '[deːɐ̯ ˈbʊs]', '公交车', 'Der Bus kommt zu spät.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (932, 23, 'Die Bahn', 'DE', '[diː ˈbaːn]', '火车/地铁', 'Die Bahn ist ein beliebtes Verkehrsmittel.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (933, 23, 'Das Fahrrad', 'DE', '[das ˈfaːɐ̯ʁaːt]', '自行车', 'Ich fahre mit dem Fahrrad zur Arbeit.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (934, 23, 'Das Ticket', 'DE', '[das ˈtɪkɛt]', '票', 'Ein Ticket nach Hamburg, bitte.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (935, 23, 'Der Weg', 'DE', '[deːɐ̯ ˈveːk]', '路/道路', 'Kennen Sie den Weg zum Bahnhof?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (936, 23, 'Die Karte', 'DE', '[diː ˈkaʁtə]', '地图/卡', 'Haben Sie eine Karte von Berlin?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (937, 23, 'Der Koffer', 'DE', '[deːɐ̯ ˈkɔfɐ]', '行李箱', 'Mein Koffer ist zu schwer.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (938, 23, 'Der Urlaub', 'DE', '[deːɐ̯ ˈuːɐ̯laʊ̯p]', '假期', 'Wir planen unseren Urlaub.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (939, 23, 'Die Reise', 'DE', '[diː ˈʁaɪ̯zə]', '旅行', 'Die Reise war sehr schön.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (940, 23, 'Das Geld', 'DE', '[das ˈɡɛlt]', '钱', 'Das Geld ist alle.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (941, 23, 'Der Euro', 'DE', '[deːɐ̯ ˈɔʏʁo]', '欧元', 'Zehn Euro kosten die Karten.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (942, 23, 'Teuer', 'DE', '[ˈtɔʏɐ]', '昂贵的', 'Das ist viel zu teuer.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (943, 23, 'Billig', 'DE', '[ˈbɪlɪç]', '便宜的', 'Das Hemd war sehr billig.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (944, 23, 'Der Preis', 'DE', '[deːɐ̯ ˈpʁaɪ̯s]', '价格', 'Was kostet das? Wie ist der Preis?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (945, 23, 'Gut', 'DE', '[ɡuːt]', '好的', 'Das ist eine gute Idee.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (946, 23, 'Schlecht', 'DE', '[ʃlɛçt]', '坏的/差的', 'Das Wetter ist schlecht.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (947, 23, 'Groß', 'DE', '[ɡʁoːs]', '大的', 'Das Haus ist sehr groß.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (948, 23, 'Klein', 'DE', '[klaɪ̯n]', '小的', 'Mein Bruder ist noch klein.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (949, 23, 'Alt', 'DE', '[alt]', '老的/旧的', 'Mein Auto ist sehr alt.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (950, 23, 'Neu', 'DE', '[nɔʏ]', '新的', 'Das ist mein neues Handy.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (951, 23, 'Schön', 'DE', '[ʃøːn]', '漂亮的/美好的', 'Sie ist eine schöne Frau.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (952, 23, 'Hässlich', 'DE', '[ˈhɛslɪç]', '丑陋的', 'Das Gebäude ist hässlich.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (953, 23, 'Schnell', 'DE', '[ʃnɛl]', '快的', 'Der Zug ist sehr schnell.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (954, 23, 'Langsam', 'DE', '[ˈlaŋzaːm]', '慢的', 'Bitte sprechen Sie langsam.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (955, 23, 'Leicht', 'DE', '[laɪ̯çt]', '容易的/轻的', 'Das ist nicht schwer, das ist leicht.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (956, 23, 'Schwer', 'DE', '[ʃveːɐ̯]', '困难的/重的', 'Die Prüfung war sehr schwer.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (957, 23, 'Kalt', 'DE', '[kalt]', '冷的', 'Das Wasser ist zu kalt.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (958, 23, 'Warm', 'DE', '[vaʁm]', '热的/暖和的', 'Ist das Essen noch warm?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (959, 23, 'Heiß', 'DE', '[haɪ̯s]', '烫的/热的', 'Der Kaffee ist zu heiß.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (960, 23, 'Kurz', 'DE', '[kʊʁts]', '短的', 'Meine Haare sind zu lang, ich will sie kurz.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (961, 23, 'Lang', 'DE', '[laŋ]', '长的', 'Der Film ist sehr lang.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (962, 23, 'Voll', 'DE', '[fɔl]', '满的', 'Der Bus ist voll.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (963, 23, 'Leer', 'DE', '[leːɐ̯]', '空的', 'Die Flasche ist leer.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (964, 23, 'Richtig', 'DE', '[ˈʁɪçtɪç]', '正确的', 'Das ist richtig so.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (965, 23, 'Falsch', 'DE', '[falʃ]', '错误的', 'Das Wort ist falsch geschrieben.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (966, 23, 'Müde', 'DE', '[ˈmyːdə]', '累的', 'Ich bin müde, ich will schlafen.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (967, 23, 'Hungrig', 'DE', '[ˈhʊŋʁɪç]', '饿的', 'Hast du Hunger? Ich bin hungrig.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (968, 23, 'Durstig', 'DE', '[ˈdʊʁstɪç]', '渴的', 'Ich habe Durst.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (969, 23, 'Krank', 'DE', '[kʁaŋk]', '生病的', 'Er ist krank und bleibt zu Hause.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (970, 23, 'Gesund', 'DE', '[ɡəˈzʊnt]', '健康的', 'Gemüse ist gesund.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (971, 23, 'Glücklich', 'DE', '[ˈɡlʏklɪç]', '幸福的/快乐的', 'Sie ist glücklich verheiratet.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (972, 23, 'Traurig', 'DE', '[ˈtʁaʊ̯ʁɪç]', '悲伤的', 'Warum bist du traurig?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (973, 23, 'Böse', 'DE', '[ˈbøːzə]', '生气的/坏的', 'Sei nicht böse auf mich.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (974, 23, 'Angst', 'DE', '[aŋst]', '害怕', 'Hast du Angst vor Hunden?', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (975, 23, 'Liebe', 'DE', '[ˈliːbə]', '爱', 'Die Liebe ist wichtig.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (976, 23, 'Das Leben', 'DE', '[das ˈleːbn̩]', '生活', 'Das Leben ist schön.', 1, '2026-04-27 19:31:43', '2026-04-27 19:31:43');
INSERT INTO `word` VALUES (977, 24, 'Bonjour', 'FR', '[bɔ̃ʒuʁ]', '你好/您好', 'Bonjour, comment allez-vous ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (978, 24, 'Salut', 'FR', '[saly]', '你好/再见 (非正式)', 'Salut ! Ça va ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (979, 24, 'Bonsoir', 'FR', '[bɔ̃swaʁ]', '晚上好', 'Bonsoir, madame.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (980, 24, 'Au revoir', 'FR', '[o ʁəvwaʁ]', '再见', 'Au revoir et à bientôt.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (981, 24, 'Merci', 'FR', '[mɛʁsi]', '谢谢', 'Merci beaucoup pour votre aide.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (982, 24, 'S\'il vous plaît', 'FR', '[sil vu plɛ]', '请 (正式)', 'Un café, s\'il vous plaît.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (983, 24, 'S\'il te plaît', 'FR', '[sil tə plɛ]', '请 (非正式)', 'Passe-moi le sel, s\'il te plaît.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (984, 24, 'Oui', 'FR', '[wi]', '是', 'Oui, c\'est vrai.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (985, 24, 'Non', 'FR', '[nɔ̃]', '不/不是', 'Non, je ne comprends pas.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (986, 24, 'Excusez-moi', 'FR', '[ɛkskyze mwa]', '对不起/打扰一下', 'Excusez-moi, où sont les toilettes ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (987, 24, 'Pardon', 'FR', '[paʁdɔ̃]', '对不起/请再说一遍', 'Pardon, pouvez-vous répéter ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (988, 24, 'Comment ça va ?', 'FR', '[kɔmɑ̃ sa va]', '你好吗？/怎么样？', 'Comment ça va ? Très bien.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (989, 24, 'Ça va bien.', 'FR', '[sa va bjɛ̃]', '很好。', 'Merci, ça va bien.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (990, 24, 'Bienvenue', 'FR', '[bjɛ̃vəny]', '欢迎', 'Bienvenue à Paris !', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (991, 24, 'L\'addition', 'FR', '[ladisjɔ̃]', '账单', 'L\'addition, s\'il vous plaît.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (992, 24, 'Un ami', 'FR', '[œ̃n‿ami]', '朋友 (男)', 'Pierre est mon ami.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (993, 24, 'Une amie', 'FR', '[yn‿ami]', '朋友 (女)', 'Marie est mon amie.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (994, 24, 'La famille', 'FR', '[la famij]', '家庭', 'J\'aime ma famille.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (995, 24, 'Le père', 'FR', '[lə pɛʁ]', '父亲', 'Mon père est ingénieur.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (996, 24, 'La mère', 'FR', '[la mɛʁ]', '母亲', 'Ma mère cuisine très bien.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (997, 24, 'Le fils', 'FR', '[lə fis]', '儿子', 'C\'est le fils de Paul.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (998, 24, 'La fille', 'FR', '[la fij]', '女儿/女孩', 'C\'est ma fille.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (999, 24, 'Le frère', 'FR', '[lə fʁɛʁ]', '兄弟', 'J\'ai un frère et une sœur.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1000, 24, 'La sœur', 'FR', '[la sœʁ]', '姐妹', 'Ma sœur habite à Lyon.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1001, 24, 'L\'homme', 'FR', '[lɔm]', '男人/丈夫', 'C\'est un homme gentil.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1002, 24, 'La femme', 'FR', '[la fam]', '女人/妻子', 'C\'est une femme intelligente.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1003, 24, 'L\'enfant', 'FR', '[lɑ̃fɑ̃]', '孩子', 'Les enfants jouent dans le parc.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1004, 24, 'Le garçon', 'FR', '[le ɡaʁsɔ̃]', '男孩/服务员', 'Le garçon apporte le menu.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1005, 24, 'Le monsieur', 'FR', '[lə məsjø]', '先生', 'Le monsieur attend dehors.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1006, 24, 'La dame', 'FR', '[la dam]', '女士', 'La dame porte une robe rouge.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1007, 24, 'Un', 'FR', '[œ̃]', '一', 'Un, deux, trois.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1008, 24, 'Deux', 'FR', '[dø]', '二', 'J\'ai deux chats.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1009, 24, 'Trois', 'FR', '[tʁwa]', '三', 'Il est trois heures.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1010, 24, 'Quatre', 'FR', '[katʁ]', '四', 'Quatre saisons.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1011, 24, 'Cinq', 'FR', '[sɛ̃k]', '五', 'Cinq minutes.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1012, 24, 'Six', 'FR', '[sis]', '六', 'Six pommes.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1013, 24, 'Sept', 'FR', '[sɛt]', '七', 'Sept jours.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1014, 24, 'Huit', 'FR', '[ɥit]', '八', 'Huit personnes.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1015, 24, 'Neuf', 'FR', '[nœf]', '九', 'Neuf heures.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1016, 24, 'Dix', 'FR', '[dis]', '十', 'Dix doigts.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1017, 24, 'Onze', 'FR', '[ɔ̃z]', '十一', 'Onze ans.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1018, 24, 'Douze', 'FR', '[duz]', '十二', 'Douze mois.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1019, 24, 'Vingt', 'FR', '[vɛ̃]', '二十', 'Vingt euros.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1020, 24, 'Trente', 'FR', '[tʁɑ̃t]', '三十', 'Trente minutes.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1021, 24, 'Quarante', 'FR', '[kaʁɑ̃t]', '四十', 'Quarante jours.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1022, 24, 'Cinquante', 'FR', '[sɛ̃kɑ̃t]', '五十', 'Cinquante pour cent.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1023, 24, 'Soixante', 'FR', '[swasɑ̃t]', '六十', 'Soixante secondes.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1024, 24, 'Cent', 'FR', '[sɑ̃]', '一百', 'Cent dollars.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1025, 24, 'Mille', 'FR', '[mil]', '一千', 'Mille mercis.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1026, 24, 'Le temps', 'FR', '[lə tɑ̃]', '时间/天气', 'Le temps passe vite.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1027, 24, 'L\'heure', 'FR', '[lœʁ]', '小时/时间', 'Quelle heure est-il ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1028, 24, 'La minute', 'FR', '[la minyt]', '分钟', 'Une minute, s\'il vous plaît.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1029, 24, 'La seconde', 'FR', '[la səɡɔ̃d]', '秒', 'Attendez une seconde.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1030, 24, 'Aujourd\'hui', 'FR', '[oʒuʁdɥi]', '今天', 'Aujourd\'hui, il fait beau.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1031, 24, 'Demain', 'FR', '[dəmɛ̃]', '明天', 'À demain !', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1032, 24, 'Hier', 'FR', '[ijɛʁ]', '昨天', 'Hier soir, j\'ai dîné tard.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1033, 24, 'Maintenant', 'FR', '[mɛ̃tnɑ̃]', '现在', 'Maintenant ou jamais.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1034, 24, 'Tôt', 'FR', '[to]', '早/提早', 'Il est venu trop tôt.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1035, 24, 'Tard', 'FR', '[taʁ]', '晚/迟到', 'Ne rentre pas tard.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1036, 24, 'Le matin', 'FR', '[lə matɛ̃]', '早晨/上午', 'Le matin, je bois du café.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1037, 24, 'L\'après-midi', 'FR', '[lapʁɛmidi]', '下午', 'Bon après-midi.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1038, 24, 'Le soir', 'FR', '[lə swaʁ]', '晚上/傍晚', 'Le soir, je regarde la télé.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1039, 24, 'La nuit', 'FR', '[la nɥi]', '夜晚', 'Bonne nuit.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1040, 24, 'La semaine', 'FR', '[la səmɛn]', '星期/周', 'Une semaine de vacances.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1041, 24, 'Le week-end', 'FR', '[lə wikɛnd]', '周末', 'Bon week-end !', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1042, 24, 'Le lundi', 'FR', '[lə lə̃di]', '星期一', 'Le lundi, c\'est difficile.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1043, 24, 'Le mardi', 'FR', '[lə maʁdi]', '星期二', 'Fermé le mardi.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1044, 24, 'Le mercredi', 'FR', '[lə mɛʁkrədi]', '星期三', 'Mercredi après-midi.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1045, 24, 'Le jeudi', 'FR', '[lə ʒədi]', '星期四', 'Jeudi prochain.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1046, 24, 'Le vendredi', 'FR', '[lə vɑ̃drədi]', '星期五', 'Vendredi soir.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1047, 24, 'Le samedi', 'FR', '[lə samdi]', '星期六', 'Samedi matin.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1048, 24, 'Le dimanche', 'FR', '[lə dimɑ̃ʃ]', '星期日', 'Dimanche de Pâques.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1049, 24, 'Le mois', 'FR', '[lə mwa]', '月/月份', 'Un mois complet.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1050, 24, 'L\'année', 'FR', '[lane]', '年', 'Bonne année !', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1051, 24, 'La maison', 'FR', '[la mɛzɔ̃]', '房子', 'Ma maison est grande.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1052, 24, 'La chambre', 'FR', '[la ʃɑ̃bʁ]', '房间/卧室', 'Une chambre double.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1053, 24, 'La cuisine', 'FR', '[la kɥizin]', '厨房', 'La cuisine française.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1054, 24, 'Le salon', 'FR', '[lə salɔ̃]', '客厅/起居室', 'Dans le salon.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1055, 24, 'La porte', 'FR', '[la pɔʁt]', '门', 'Ouvre la porte.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1056, 24, 'La fenêtre', 'FR', '[la fənɛtʁ]', '窗户', 'Par la fenêtre.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1057, 24, 'La table', 'FR', '[la tabl]', '桌子', 'À table !', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1058, 24, 'La chaise', 'FR', '[la ʃɛz]', '椅子', 'Asseyez-vous sur la chaise.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1059, 24, 'Le lit', 'FR', '[lə li]', '床', 'Aller au lit.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1060, 24, 'L\'eau', 'FR', '[lo]', '水', 'Un verre d\'eau.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1061, 24, 'Le pain', 'FR', '[lə pɛ̃]', '面包', 'Le pain et le beurre.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1062, 24, 'Le lait', 'FR', '[lə lɛ]', '牛奶', 'Un bol de lait.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1063, 24, 'Le café', 'FR', '[lə kafe]', '咖啡', 'Un café noir.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1064, 24, 'Le thé', 'FR', '[lə te]', '茶', 'Un thé au citron.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1065, 24, 'Le vin', 'FR', '[lə vɛ̃]', '葡萄酒', 'Un verre de vin rouge.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1066, 24, 'La bière', 'FR', '[la bjɛʁ]', '啤酒', 'Une bière pression.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1067, 24, 'La pomme', 'FR', '[la pɔm]', '苹果', 'Une pomme par jour.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1068, 24, 'La viande', 'FR', '[la vjɑ̃d]', '肉', 'Je ne mange pas de viande.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1069, 24, 'Le poisson', 'FR', '[lə pwasɔ̃]', '鱼', 'Poisson ou viande ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1070, 24, 'Le fromage', 'FR', '[lə fʁɔmaʒ]', '奶酪', 'Le plateau de fromages.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1071, 24, 'Les fruits', 'FR', '[le fʁɥi]', '水果', 'J\'aime les fruits.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1072, 24, 'Les légumes', 'FR', '[le legym]', '蔬菜', 'Mangez vos légumes.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1073, 24, 'La voiture', 'FR', '[la vwatyʁ]', '汽车', 'Ma voiture est rouge.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1074, 24, 'Le bus', 'FR', '[lə bys]', '公共汽车', 'Prendre le bus.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1075, 24, 'Le train', 'FR', '[lə tʁɛ̃]', '火车', 'Le train part à 8h.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1076, 24, 'Le métro', 'FR', '[lə metro]', '地铁', 'Le plan du métro.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1077, 24, 'L\'avion', 'FR', '[lavjɔ̃]', '飞机', 'En avion.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1078, 24, 'Le vélo', 'FR', '[lə velo]', '自行车', 'Faire du vélo.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1079, 24, 'La ville', 'FR', '[la vil]', '城市', 'La ville de Paris.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1080, 24, 'La rue', 'FR', '[la ʁy]', '街道', 'Dans la rue.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1081, 24, 'L\'adresse', 'FR', '[ladʁɛs]', '地址', 'Donnez-moi votre adresse.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1082, 24, 'Le travail', 'FR', '[lə tʁavaj]', '工作', 'Chercher du travail.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1083, 24, 'L\'école', 'FR', '[lekɔl]', '学校', 'Aller à l\'école.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1084, 24, 'L\'étudiant', 'FR', '[letydjɑ̃]', '学生 (男)', 'Il est étudiant.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1085, 24, 'L\'étudiante', 'FR', '[letydjɑ̃t]', '学生 (女)', 'Elle est étudiante.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1086, 24, 'Le livre', 'FR', '[lə livʁ]', '书', 'Lire un livre.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1087, 24, 'Le stylo', 'FR', '[lə stilo]', '钢笔', 'Un stylo bleu.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1088, 24, 'L\'argent', 'FR', '[laʁʒɑ̃]', '钱', 'Pas d\'argent, pas de Suisse.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1089, 24, 'Le prix', 'FR', '[lə pʁi]', '价格', 'Quel est le prix ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1090, 24, 'Cher', 'FR', '[ʃɛʁ]', '昂贵的', 'C\'est trop cher.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1091, 24, 'Bon marché', 'FR', '[bɔ̃ maʁʃe]', '便宜的', 'C\'est bon marché.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1092, 24, 'Grand', 'FR', '[ɡʁɑ̃]', '大的', 'Un grand homme.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1093, 24, 'Petit', 'FR', '[pəti]', '小的', 'Un petit problème.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1094, 24, 'Nouveau', 'FR', '[nuvo]', '新的', 'Une nouvelle voiture.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1095, 24, 'Vieux', 'FR', '[vjø]', '老的/旧的', 'Un vieux château.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1096, 24, 'Bon', 'FR', '[bɔ̃]', '好的', 'C\'est bon.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1097, 24, 'Mauvais', 'FR', '[movɛ]', '坏的', 'C\'est mauvais.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1098, 24, 'Beau', 'FR', '[bo]', '美丽的/漂亮的', 'Il fait beau.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1099, 24, 'Joli', 'FR', '[ʒɔli]', '漂亮的', 'Une jolie fille.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1100, 24, 'Jeune', 'FR', '[ʒœn]', '年轻的', 'Il est jeune.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1101, 24, 'Heureux', 'FR', '[œʁø]', '幸福的/高兴的', 'Il est heureux.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1102, 24, 'Triste', 'FR', '[tʁist]', '悲伤的', 'Elle est triste.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1103, 24, 'Fatigué', 'FR', '[fatiɡe]', '累的', 'Je suis fatigué.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1104, 24, 'Malade', 'FR', '[malad]', '生病的', 'Il est malade.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1105, 24, 'Froid', 'FR', '[fʁwa]', '冷的', 'Il fait froid.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1106, 24, 'Chaud', 'FR', '[ʃo]', '热的', 'Il fait chaud.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1107, 24, 'Facile', 'FR', '[fasil]', '容易的', 'C\'est facile.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1108, 24, 'Difficile', 'FR', '[difisil]', '困难的', 'C\'est difficile.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1109, 24, 'Important', 'FR', '[ɛ̃pɔʁtɑ̃]', '重要的', 'C\'est important.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1110, 24, 'Possible', 'FR', '[pɔsibl]', '可能的', 'C\'est possible.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1111, 24, 'Impossible', 'FR', '[ɛ̃pɔsibl]', '不可能的', 'C\'est impossible.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1112, 24, 'Avec', 'FR', '[avɛk]', '和/带有', 'Avec moi.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1113, 24, 'Sans', 'FR', '[sɑ̃]', '没有/无', 'Sans sucre.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1114, 24, 'Pour', 'FR', '[puʁ]', '为了/给', 'Pour toi.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1115, 24, 'Contre', 'FR', '[kɔ̃tʁ]', '反对/靠着', 'Contre la montre.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1116, 24, 'Chez', 'FR', '[ʃe]', '在...家', 'Chez le médecin.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1117, 24, 'Dans', 'FR', '[dɑ̃]', '在...里面', 'Dans la boîte.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1118, 24, 'Sur', 'FR', '[syʁ]', '在...上面', 'Sur la table.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1119, 24, 'Sous', 'FR', '[su]', '在...下面', 'Sous le lit.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1120, 24, 'Devant', 'FR', '[dəvɑ̃]', '在...前面', 'Devant le cinéma.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1121, 24, 'Derrière', 'FR', '[dɛʁjɛʁ]', '在...后面', 'Derrière la maison.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1122, 24, 'À côté de', 'FR', '[a kote də]', '在...旁边', 'À côté de la banque.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1123, 24, 'Près de', 'FR', '[pʁɛ də]', '靠近', 'Près de la gare.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1124, 24, 'Loin de', 'FR', '[lwɛ̃ də]', '远离', 'Loin d\'ici.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1125, 24, 'Pendant', 'FR', '[pɑ̃dɑ̃]', '在...期间', 'Pendant les vacances.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1126, 24, 'Après', 'FR', '[apʁɛ]', '在...之后', 'Après le dîner.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1127, 24, 'Avant', 'FR', '[avɑ̃]', '在...之前', 'Avant hier.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1128, 24, 'Depuis', 'FR', '[dəpɥi]', '自从', 'Depuis quand ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1129, 24, 'Parce que', 'FR', '[paʁs kə]', '因为', 'Parce que c\'est comme ça.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1130, 24, 'Donc', 'FR', '[dɔ̃k]', '所以/因此', 'Donc, voilà.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1131, 24, 'Mais', 'FR', '[mɛ]', '但是', 'Mais non !', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1132, 24, 'Ou', 'FR', '[u]', '或者', 'Thé ou café ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1133, 24, 'Et', 'FR', '[e]', '和/与', 'Toi et moi.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1134, 24, 'Si', 'FR', '[si]', '如果/是否', 'Si tu veux.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1135, 24, 'Quand', 'FR', '[kɑ̃]', '当...时/什么时候', 'Quand pars-tu ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1137, 24, 'Pourquoi', 'FR', '[puʁkwa]', '为什么', 'Pourquoi pas ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1138, 24, 'Comment', 'FR', '[kɔmɑ̃]', '如何/怎么', 'Comment ça marche ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1139, 24, 'Combien', 'FR', '[kɔ̃bjɛ̃]', '多少', 'Combien ça coûte ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1140, 24, 'Qui', 'FR', '[ki]', '谁', 'Qui est là ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1141, 24, 'Que', 'FR', '[kə]', '什么/那个', 'Qu\'est-ce que c\'est ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1142, 24, 'Quoi', 'FR', '[kwa]', '什么', 'De quoi parles-tu ?', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1143, 24, 'Tout', 'FR', '[tu]', '一切/所有', 'Tout le monde.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1144, 24, 'Rien', 'FR', '[ʁjɛ̃]', '没有什么', 'Rien du tout.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1145, 24, 'Chacun', 'FR', '[ʃakœ̃]', '每个人', 'Chacun son tour.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1146, 24, 'Autre', 'FR', '[otʁ]', '其他的', 'Une autre fois.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1147, 24, 'Même', 'FR', '[mɛm]', '相同的/甚至', 'La même chose.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1148, 24, 'Seul', 'FR', '[sœl]', '唯一的/独自的', 'Tout seul.', 1, '2026-04-27 22:48:28', '2026-04-27 22:48:28');
INSERT INTO `word` VALUES (1149, 25, 'Hallo', 'ES', '[haˈloː]', '你好', 'Hallo, wie geht es dir?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1150, 25, 'Guten Tag', 'ES', '[ˈɡuːtn̩ ˈtaːk]', '日安/你好', 'Guten Tag, mein Name ist Hans.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1151, 25, 'Guten Morgen', 'ES', '[ˈɡuːtn̩ ˈmɔʁɡn̩]', '早上好', 'Guten Morgen! Hast du gut geschlafen?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1152, 25, 'Guten Abend', 'ES', '[ˈɡuːtn̩ ˈʔaːbn̩t]', '晚上好', 'Guten Abend, meine Damen und Herren.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1153, 25, 'Auf Wiedersehen', 'ES', '[aʊf ˈviːdɐzeːən]', '再见', 'Auf Wiedersehen und bis bald!', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1154, 25, 'Tschüss', 'ES', '[ˈtʃʏs]', '再见 (非正式)', 'Tschüss, bis morgen!', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1155, 25, 'Danke', 'ES', '[ˈdaŋkə]', '谢谢', 'Vielen Dank für Ihre Hilfe.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1156, 25, 'Bitte', 'ES', '[ˈbɪtə]', '请/不客气', 'Einmal Kaffee, bitte.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1157, 25, 'Ja', 'ES', '[jaː]', '是', 'Ja, das ist richtig.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1158, 25, 'Nein', 'ES', '[naɪn]', '不/不是', 'Nein, danke, ich möchte nichts.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1159, 25, 'Entschuldigung', 'ES', '[ɛntˈʃʊldɪɡʊŋ]', '对不起/打扰一下', 'Entschuldigung, wo ist die Toilette?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1160, 25, 'Wie geht es Ihnen?', 'ES', '[viː ˈɡeːt ɛs ˈiːnən]', '您好吗？', 'Wie geht es Ihnen heute?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1161, 25, 'Mir geht es gut.', 'ES', '[miːɐ̯ ɡeːt ɛs ɡuːt]', '我很好。', 'Mir geht es gut, danke.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1162, 25, 'Ich', 'ES', '[ɪç]', '我', 'Ich heiße Peter.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1163, 25, 'Du', 'ES', '[duː]', '你', 'Kennst du ihn?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1164, 25, 'Er', 'ES', '[eːɐ̯]', '他', 'Er ist mein Bruder.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1165, 25, 'Sie', 'ES', '[ziː]', '她/您/他们', 'Sie ist sehr nett.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1166, 25, 'Wir', 'ES', '[viːɐ̯]', '我们', 'Wir kommen aus China.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1167, 25, 'Ihr', 'ES', '[iːɐ̯]', '你们', 'Wie geht es euch?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1168, 25, 'Was', 'ES', '[vas]', '什么', 'Was ist das?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1169, 25, 'Wer', 'ES', '[veːɐ̯]', '谁', 'Wer ist das?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1170, 25, 'Wo', 'ES', '[voː]', '哪里', 'Wo wohnst du?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1171, 25, 'Wann', 'ES', '[van]', '什么时候', 'Wann hast du Zeit?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1172, 25, 'Warum', 'ES', '[vaˈʁʊm]', '为什么', 'Warum lernst du Deutsch?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1173, 25, 'Wie', 'ES', '[viː]', '如何/怎样', 'Wie alt bist du?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1174, 25, 'Und', 'ES', '[ʊnt]', '和', 'Kaffee und Tee.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1175, 25, 'Oder', 'ES', '[ˈoːdɐ]', '或者', 'Möchtest du Tee oder Kaffee?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1176, 25, 'Aber', 'ES', '[ˈaːbɐ]', '但是', 'Es ist klein, aber fein.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1177, 25, 'Dass', 'ES', '[das]', '(连词)那/那个', 'Ich glaube, dass er kommt.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1178, 25, 'Nicht', 'ES', '[nɪçt]', '不/没有', 'Das ist nicht gut.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1179, 25, 'Kein', 'ES', '[kaɪn]', '没有(冠词)', 'Ich habe kein Geld.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1180, 25, 'Hier', 'ES', '[hiːɐ̯]', '这里', 'Kommen Sie bitte hierher.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1181, 25, 'Dort', 'ES', '[dɔʁt]', '那里', 'Das Auto steht dort.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1182, 25, 'Heute', 'ES', '[ˈhɔʏtə]', '今天', 'Heute ist Montag.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1183, 25, 'Morgen', 'ES', '[ˈmɔʁɡn̩]', '明天/早晨', 'Morgen gehe ich ins Kino.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1184, 25, 'Gestern', 'ES', '[ˈɡɛstɐn]', '昨天', 'Gestern war ich krank.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1185, 25, 'Jetzt', 'ES', '[jeːtst]', '现在', 'Jetzt verstehe ich.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1186, 25, 'Später', 'ES', '[ˈʃpɛːtɐ]', '稍后', 'Bis später!', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1187, 25, 'Immer', 'ES', '[ˈɪmɐ]', '总是', 'Er ist immer pünktlich.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1188, 25, 'Oft', 'ES', '[ɔft]', '经常', 'Wir essen oft Pizza.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1189, 25, 'Manchmal', 'ES', '[ˈmançmaːl]', '有时', 'Manchmal regnet es.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1190, 25, 'Nie', 'ES', '[niː]', '从不', 'Ich rauche nie.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1191, 25, 'Gut', 'ES', '[ɡuːt]', '好', 'Das schmeckt gut.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1192, 25, 'Schlecht', 'ES', '[ʃlɛçt]', '坏/差', 'Das Wetter ist schlecht.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1193, 25, 'Groß', 'ES', '[ɡʁoːs]', '大/高', 'Er ist sehr groß.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1194, 25, 'Klein', 'ES', '[klaɪn]', '小', 'Das Kind ist noch klein.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1195, 25, 'Alt', 'ES', '[alt]', '老/旧', 'Mein Auto ist alt.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1196, 25, 'Neu', 'ES', '[nɔʏ]', '新', 'Das ist ein neues Handy.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1197, 25, 'Schön', 'ES', '[ʃøːn]', '漂亮/美好', 'Sie ist sehr schön.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1198, 25, 'Hässlich', 'ES', '[ˈhɛslɪç]', '丑陋', 'Das finde ich hässlich.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1199, 25, 'Teuer', 'ES', '[ˈtɔʏɐ]', '贵', 'Das Kleid ist zu teuer.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1200, 25, 'Billig', 'ES', '[ˈbɪlɪç]', '便宜', 'Das ist sehr billig.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1201, 25, 'Heiß', 'ES', '[haɪs]', '热', 'Der Kaffee ist heiß.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1202, 25, 'Kalt', 'ES', '[kalt]', '冷', 'Das Wasser ist zu kalt.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1203, 25, 'Warm', 'ES', '[varm]', '温暖', 'Es ist warm heute.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1204, 25, 'Schnell', 'ES', '[ʃnɛl]', '快', 'Der Zug ist schnell.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1205, 25, 'Langsam', 'ES', '[ˈlanzaːm]', '慢', 'Sprechen Sie bitte langsam.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1206, 25, 'Leicht', 'ES', '[laɪçt]', '容易/轻', 'Deutsch ist nicht leicht.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1207, 25, 'Schwer', 'ES', '[ʃveːɐ̯]', '困难/重', 'Die Aufgabe ist schwer.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1208, 25, 'Müde', 'ES', '[ˈmyːdə]', '累', 'Ich bin sehr müde.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1209, 25, 'Hungrig', 'ES', '[ˈhʊŋʁɪç]', '饿', 'Hast du Hunger?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1210, 25, 'Durstig', 'ES', '[ˈdʊʁstɪç]', '渴', 'Ich habe Durst.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1211, 25, 'Glücklich', 'ES', '[ˈɡlʏklɪç]', '幸福/高兴', 'Ich bin glücklich.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1212, 25, 'Traurig', 'ES', '[ˈtʁaʊʁɪç]', '伤心', 'Warum bist du traurig?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1213, 25, 'Böse', 'ES', '[ˈbøːzə]', '生气/坏', 'Sei nicht böse auf mich.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1214, 25, 'Krank', 'ES', '[kʁaŋk]', '生病', 'Er ist krank.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1215, 25, 'Gesund', 'ES', '[ɡəˈzʊnt]', '健康', 'Das ist gesund.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1216, 25, 'Der Mann', 'ES', '[deːɐ̯ man]', '男人/丈夫', 'Der Mann liest eine Zeitung.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1217, 25, 'Die Frau', 'ES', '[diː fʁaʊ]', '女人/妻子', 'Die Frau kocht Abendbrot.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1218, 25, 'Das Kind', 'ES', '[das kɪnt]', '孩子', 'Das Kind spielt im Park.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1219, 25, 'Der Junge', 'ES', '[deːɐ̯ ˈjʊŋə]', '男孩', 'Der Junge lernt Deutsch.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1220, 25, 'Das Mädchen', 'ES', '[das ˈmɛːtçən]', '女孩', 'Das Mädchen singt ein Lied.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1221, 25, 'Der Vater', 'ES', '[deːɐ̯ ˈfaːtɐ]', '父亲', 'Mein Vater ist Ingenieur.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1222, 25, 'Die Mutter', 'ES', '[diː ˈmʊtɐ]', '母亲', 'Meine Mutter backt Kuchen.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1223, 25, 'Die Eltern', 'ES', '[diː ˈɛltɐn]', '父母', 'Meine Eltern wohnen in Berlin.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1224, 25, 'Der Bruder', 'ES', '[deːɐ̯ ˈbʁuːdɐ]', '兄弟', 'Mein Bruder heißt Tom.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1225, 25, 'Die Schwester', 'ES', '[diː ˈʃvɛstɐ]', '姐妹', 'Meine Schwester studiert.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1226, 25, 'Der Freund', 'ES', '[deːɐ̯ fʁɔʏnt]', '男朋友/男性朋友', 'Das ist mein bester Freund.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1227, 25, 'Die Freundin', 'ES', '[diː ˈfʁɔʏndɪn]', '女朋友/女性朋友', 'Meine Freundin kommt aus Spanien.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1228, 25, 'Das Baby', 'ES', '[das ˈbeːbi]', '婴儿', 'Das Baby schläft.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1229, 25, 'Die Familie', 'ES', '[diː famiːli̯ə]', '家庭', 'Meine Familie ist groß.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1230, 25, 'Der Lehrer', 'ES', '[deːɐ̯ ˈleːʁɐ]', '男老师', 'Der Lehrer erklärt die Grammatik.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1231, 25, 'Die Lehrerin', 'ES', '[diː ˈleːʁəʁɪn]', '女老师', 'Die Lehrerin ist sehr nett.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1232, 25, 'Der Schüler', 'ES', '[deːɐ̯ ˈʃyːlɐ]', '男学生', 'Der Schüler macht Hausaufgaben.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1233, 25, 'Der Student', 'ES', '[deːɐ̯ ʃtuˈdɛnt]', '大学生', 'Der Student wohnt im Wohnheim.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1234, 25, 'Der Arzt', 'ES', '[deːɐ̯ aːɐ̯tst]', '男医生', 'Der Arzt hilft dem Patienten.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1235, 25, 'Die Ärztin', 'ES', '[diː ˈɛːɐ̯tstɪn]', '女医生', 'Die Ärztin schreibt ein Rezept.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1236, 25, 'Das Haus', 'ES', '[das haʊs]', '房子', 'Wir haben ein großes Haus.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1237, 25, 'Die Wohnung', 'ES', '[diː ˈvoːnʊŋ]', '公寓', 'Meine Wohnung ist klein.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1238, 25, 'Das Zimmer', 'ES', '[das ˈt͡sɪmɐ]', '房间', 'Mein Zimmer ist unordentlich.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1239, 25, 'Die Küche', 'ES', '[diː ˈkʏçə]', '厨房', 'Die Küche ist modern.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1240, 25, 'Das Bad', 'ES', '[das baːt]', '浴室/卫生间', 'Das Bad ist im ersten Stock.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1241, 25, 'Die Tür', 'ES', '[diː tyːɐ̯]', '门', 'Mach bitte die Tür zu.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1242, 25, 'Das Fenster', 'ES', '[das ˈfɛnstɐ]', '窗户', 'Das Fenster ist offen.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1243, 25, 'Der Tisch', 'ES', '[deːɐ̯ tɪʃ]', '桌子', 'Der Tisch ist aus Holz.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1244, 25, 'Der Stuhl', 'ES', '[deːɐ̯ ʃtuːl]', '椅子', 'Setz dich auf den Stuhl.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1245, 25, 'Das Bett', 'ES', '[das bɛt]', '床', 'Ich gehe ins Bett.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1246, 25, 'Der Schrank', 'ES', '[deːɐ̯ ʃʁaŋk]', '柜子', 'Im Schrank hängen meine Kleider.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1247, 25, 'Der Computer', 'ES', '[deːɐ̯ kɔmˈpjuːtɐ]', '电脑', 'Der Computer ist kaputt.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1248, 25, 'Das Handy', 'ES', '[das ˈhɛndi]', '手机', 'Wo ist mein Handy?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1249, 25, 'Das Buch', 'ES', '[das buːx]', '书', 'Das Buch ist interessant.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1250, 25, 'Der Stift', 'ES', '[deːɐ̯ ʃtɪft]', '笔', 'Hast du einen Stift für mich?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1251, 25, 'Das Papier', 'ES', '[das paˈpiːɐ̯]', '纸', 'Ich brauche ein Blatt Papier.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1252, 25, 'Die Schule', 'ES', '[diː ˈʃuːlə]', '学校', 'Die Schule beginnt um 8 Uhr.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1253, 25, 'Die Universität', 'ES', '[diː univɛʁziˈtɛːt]', '大学', 'Er studiert an der Universität.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1254, 25, 'Die Arbeit', 'ES', '[diː ˈaʁbaɪt]', '工作', 'Die Arbeit macht Spaß.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1255, 25, 'Der Beruf', 'ES', '[deːɐ̯ bəˈʁuːf]', '职业', 'Was ist Ihr Beruf?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1256, 25, 'Die Zeit', 'ES', '[diː t͡saɪt]', '时间/时代', 'Wir haben keine Zeit.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1257, 25, 'Die Uhr', 'ES', '[diː ˈuːɐ̯]', '钟/表', 'Wie spät ist es?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1258, 25, 'Die Stunde', 'ES', '[diː ˈʃtʊndə]', '小时/课时', 'Eine Stunde hat 60 Minuten.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1259, 25, 'Der Tag', 'ES', '[deːɐ̯ taːk]', '天/日子', 'Heute ist ein schöner Tag.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1260, 25, 'Die Woche', 'ES', '[diː ˈvɔxə]', '周', 'Eine Woche hat 7 Tage.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1261, 25, 'Der Monat', 'ES', '[deːɐ̯ ˈmoːnat]', '月', 'Der nächste Monat ist Juli.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1262, 25, 'Das Jahr', 'ES', '[das jaːɐ̯]', '年', 'Das Jahr hat 12 Monate.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1263, 25, 'Montag', 'ES', '[ˈmoːntaːk]', '周一', 'Am Montag habe ich frei.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1264, 25, 'Dienstag', 'ES', '[ˈdiːnstaːk]', '周二', 'Dienstag ist der zweite Tag.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1265, 25, 'Mittwoch', 'ES', '[ˈmɪtvɔx]', '周三', 'Heute ist Mittwoch.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1266, 25, 'Donnerstag', 'ES', '[ˈdɔnɐstaːk]', '周四', 'Donnerstagabend treffen wir uns.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1267, 25, 'Freitag', 'ES', '[ˈfʁaɪ̯taːk]', '周五', 'Freitag ist mein Lieblingstag.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1268, 25, 'Samstag', 'ES', '[ˈzamstaːk]', '周六', 'Am Samstag gehe ich einkaufen.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1269, 25, 'Sonntag', 'ES', '[ˈzɔntaːk]', '周日', 'Sonntag ist Ruhetag.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1270, 25, 'Januar', 'ES', '[ˈjanuaːɐ̯]', '一月', 'Im Januar ist es kalt.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1271, 25, 'Februar', 'ES', '[ˈfeːbʁuaːɐ̯]', '二月', 'Der Februar ist kurz.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1272, 25, 'März', 'ES', '[mɛʁt͡s]', '三月', 'Im März wird es wärmer.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1273, 25, 'April', 'ES', '[aˈpʁɪl]', '四月', 'April, April!', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1274, 25, 'Mai', 'ES', '[maɪ̯]', '五月', 'Der Mai ist schön.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1275, 25, 'Juni', 'ES', '[ˈjuːni]', '六月', 'Im Juni beginnt der Sommer.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1276, 25, 'Juli', 'ES', '[ˈjuːli]', '七月', 'Der Juli ist oft heiß.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1277, 25, 'August', 'ES', '[aʊˈɡʊst]', '八月', 'Im August fahren wir in den Urlaub.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1278, 25, 'September', 'ES', '[zɛpˈtɛmbɐ]', '九月', 'Der September ist mild.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1279, 25, 'Oktober', 'ES', '[ɔkˈtoːbɐ]', '十月', 'Im Oktober feiern wir Erntedank.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1280, 25, 'November', 'ES', '[noˈvɛmbɐ]', '十一月', 'Der November ist grau.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1281, 25, 'Dezember', 'ES', '[deˈt͡sɛmbɐ]', '十二月', 'Im Dezember ist Weihnachten.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1282, 25, 'Das Essen', 'ES', '[das ˈɛsn̩]', '食物/吃', 'Das Essen schmeckt lecker.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1283, 25, 'Das Frühstück', 'ES', '[das ˈfʁʏhʃtʏk]', '早餐', 'Zum Frühstück esse ich Brötchen.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1284, 25, 'Das Mittagessen', 'ES', '[das ˈmɪtaːkˌɛsn̩]', '午餐', 'Was gibt es zum Mittagessen?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1285, 25, 'Das Abendessen', 'ES', '[das ˈaːbn̩tˌɛsn̩]', '晚餐', 'Das Abendessen ist fertig.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1286, 25, 'Das Brot', 'ES', '[das bʁoːt]', '面包', 'Ich kaufe frisches Brot.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1287, 25, 'Die Butter', 'ES', '[diː ˈbʊtɐ]', '黄油', 'Möchtest du Butter auf dem Brot?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1288, 25, 'Der Käse', 'ES', '[deːɐ̯ ˈkɛːzə]', '奶酪', 'Der Käse ist sehr würzig.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1289, 25, 'Die Wurst', 'ES', '[diː vʊʁst]', '香肠', 'Deutsche Wurst ist bekannt.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1290, 25, 'Das Fleisch', 'ES', '[das flaɪ̯ʃ]', '肉', 'Ich esse kein Fleisch.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1291, 25, 'Der Fisch', 'ES', '[deːɐ̯ fɪʃ]', '鱼', 'Fisch ist gesund.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1292, 25, 'Das Ei', 'ES', '[das aɪ̯]', '蛋', 'Zum Frühstück ein Ei.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1293, 25, 'Die Milch', 'ES', '[diː mɪlç]', '牛奶', 'Trinkst du Milch?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1294, 25, 'Der Kaffee', 'ES', '[deːɐ̯ ˈkafe]', '咖啡', 'Eine Tasse Kaffee bitte.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1295, 25, 'Der Tee', 'ES', '[deːɐ̯ ˈteː]', '茶', 'Möchtest du Tee?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1296, 25, 'Das Wasser', 'ES', '[das ˈvasɐ]', '水', 'Ein Glas Wasser, bitte.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1297, 25, 'Der Apfel', 'ES', '[deːɐ̯ ˈap͡fl̩]', '苹果', 'Ein Apfel am Tag.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1298, 25, 'Die Banane', 'ES', '[diː baˈnaːnə]', '香蕉', 'Die Banane ist gelb.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1299, 25, 'Das Gemüse', 'ES', '[das ɡəˈmyːzə]', '蔬菜', 'Gemüse ist wichtig.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1300, 25, 'Die Kartoffel', 'ES', '[diː kaʁˈtɔfl̩]', '土豆', 'Kartoffeln mit Soße.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1301, 25, 'Die Tomate', 'ES', '[diː toˈmaːtə]', '番茄', 'Die Tomate ist rot.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1302, 25, 'Der Salat', 'ES', '[deːɐ̯ zaˈlaːt]', '沙拉', 'Einen gemischten Salat.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1303, 25, 'Die Suppe', 'ES', '[diː ˈzʊpə]', '汤', 'Die Suppe ist heiß.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1304, 25, 'Der Zucker', 'ES', '[deːɐ̯ ˈt͡sʊkɐ]', '糖', 'Zucker im Kaffee?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1305, 25, 'Das Salz', 'ES', '[das zalt͡s]', '盐', 'Ein bisschen Salz.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1306, 25, 'Der Pfeffer', 'ES', '[deːɐ̯ ˈp͡fɛfɐ]', '胡椒', 'Pfeffer und Salz.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1307, 25, 'Das Restaurant', 'ES', '[das ʁɛstoˈʁɑ̃ː]', '餐厅', 'Im Restaurant essen.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1308, 25, 'Die Rechnung', 'ES', '[diː ˈʁɛçnʊŋ]', '账单', 'Die Rechnung, bitte.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1309, 25, 'Trinken', 'ES', '[ˈtʁɪŋkn̩]', '喝', 'Was möchten Sie trinken?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1310, 25, 'Essen', 'ES', '[ˈɛsn̩]', '吃', 'Wir essen zusammen.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1311, 25, 'Kochen', 'ES', '[ˈkɔxn̩]', '做饭/烹饪', 'Meine Mutter kocht gut.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1312, 25, 'Kaufen', 'ES', '[ˈkaʊ̯fn̩]', '买', 'Wo kaufst du ein?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1313, 25, 'Verkaufen', 'ES', '[fɛɐ̯ˈkaʊ̯fn̩]', '卖', 'Das Geschäft verkauft Kleidung.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1314, 25, 'Bezahlen', 'ES', '[bəˈt͡saːlən]', '支付', 'Ich bezahle mit Karte.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1315, 25, 'Kostet', 'ES', '[ˈkɔstət]', '花费', 'Wie viel kostet das?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1316, 25, 'Geben', 'ES', '[ˈɡeːbn̩]', '给', 'Gib mir bitte das Buch.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1317, 25, 'Nehmen', 'ES', '[ˈneːmən]', '拿/取', 'Ich nehme das hier.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1318, 25, 'Machen', 'ES', '[ˈmaxn̩]', '做', 'Was machst du?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1319, 25, 'Arbeiten', 'ES', '[ˈaʁbaɪ̯tn̩]', '工作', 'Er arbeitet bei Siemens.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1320, 25, 'Lernen', 'ES', '[ˈlɛʁnən]', '学习', 'Wir lernen Deutsch.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1321, 25, 'Studieren', 'ES', '[ʃtuˈdiːʁən]', '上大学', 'Sie studiert Medizin.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1322, 25, 'Lesen', 'ES', '[ˈleːzn̩]', '阅读', 'Ich lese gerne Romane.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1323, 25, 'Schreiben', 'ES', '[ˈʃʁaɪ̯bn̩]', '写', 'Schreib mir eine E-Mail.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1324, 25, 'Sprechen', 'ES', '[ˈʃpʁɛçn̩]', '说/说话', 'Sprechen Sie Englisch?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1325, 25, 'Hören', 'ES', '[ˈhøːʁən]', '听', 'Hörst du Musik?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1326, 25, 'Sehen', 'ES', '[ˈzeːən]', '看/看见', 'Ich sehe den Baum.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1327, 25, 'Schauen', 'ES', '[ˈʃaʊ̯ən]', '看/瞧', 'Schau mal!', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1328, 25, 'Verstehen', 'ES', '[fɛɐ̯ˈʃteːən]', '理解/明白', 'Verstehst du die Frage?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1329, 25, 'Wissen', 'ES', '[ˈvɪsn̩]', '知道', 'Ich weiß nicht.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1330, 25, 'Kennen', 'ES', '[ˈkɛnən]', '认识/了解', 'Kennst du diesen Mann?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1331, 25, 'Denken', 'ES', '[ˈdɛŋkn̩]', '想/认为', 'Ich denke, das ist richtig.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1332, 25, 'Glauben', 'ES', '[ˈɡlaʊ̯bn̩]', '相信/认为', 'Ich glaube dir.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1333, 25, 'Mögen', 'ES', '[ˈmøːɡn̩]', '喜欢', 'Ich mag Schokolade.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1334, 25, 'Lieben', 'ES', '[ˈliːbn̩]', '爱/热爱', 'Ich liebe dich.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1335, 25, 'Hassen', 'ES', '[ˈhasn̩]', '讨厌/恨', 'Ich hasse Gewalt.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1336, 25, 'Helfen', 'ES', '[ˈhɛlfn̩]', '帮助', 'Kann ich Ihnen helfen?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1337, 25, 'Suchen', 'ES', '[ˈzuːxn̩]', '寻找', 'Was suchst du?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1338, 25, 'Finden', 'ES', '[ˈfɪndn̩]', '找到/觉得', 'Ich finde das gut.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1339, 25, 'Bringen', 'ES', '[ˈbʁɪŋən]', '带来/拿来', 'Bitte bring mir ein Bier.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1340, 25, 'Gehen', 'ES', '[ˈɡeːən]', '走/去', 'Wir gehen nach Hause.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1341, 25, 'Kommen', 'ES', '[ˈkɔmən]', '来', 'Komm bitte her!', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1342, 25, 'Laufen', 'ES', '[ˈlaʊ̯fn̩]', '跑/走', 'Er läuft sehr schnell.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1343, 25, 'Fahren', 'ES', '[ˈfaːʁən]', '开车/乘车', 'Wir fahren mit dem Zug.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1344, 25, 'Fliegen', 'ES', '[ˈfliːɡn̩]', '飞/坐飞机', 'Wir fliegen in den Urlaub.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1345, 25, 'Schwimmen', 'ES', '[ˈʃvɪmən]', '游泳', 'Schwimmen macht Spaß.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1346, 25, 'Schlafen', 'ES', '[ˈʃlaːfn̩]', '睡觉', 'Das Baby schläft.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1347, 25, 'Aufstehen', 'ES', '[ˈaʊ̯fʃteːən]', '起床', 'Wann stehst du auf?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1348, 25, 'Anfangen', 'ES', '[ˈanˌfaŋən]', '开始', 'Der Kurs fängt an.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1349, 25, 'Aufhören', 'ES', '[ˈaʊ̯fˌhøːʁən]', '停止/结束', 'Hör auf damit!', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1350, 25, 'Tun', 'ES', '[tuːn]', '做/干', 'Tu, was du nicht lassen kannst.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1351, 25, 'Spielen', 'ES', '[ˈʃpiːlən]', '玩/演奏', 'Die Kinder spielen Fußball.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1352, 25, 'Besuchen', 'ES', '[bəˈzuːxn̩]', '拜访/参观', 'Wir besuchen das Museum.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1353, 25, 'Einladen', 'ES', '[ˈaɪ̯nˌlaːdn̩]', '邀请', 'Ich lade dich zum Essen ein.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1354, 25, 'Feiern', 'ES', '[ˈfaɪ̯ɐn]', '庆祝', 'Wir feiern ein Fest.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1355, 25, 'Wohnen', 'ES', '[ˈvoːnən]', '居住', 'Wo wohnen Sie?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1356, 25, 'Leben', 'ES', '[ˈleːbn̩]', '生活/活着', 'Wir leben in Deutschland.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1357, 25, 'Bleiben', 'ES', '[ˈblaɪ̯bn̩]', '停留/留下', 'Bleibst du noch?', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1358, 25, 'Reisen', 'ES', '[ˈʁaɪ̯zn̩]', '旅行', 'Wir reisen gerne.', 1, '2026-04-27 23:17:47', '2026-04-27 23:17:47');
INSERT INTO `word` VALUES (1359, 14, '안녕하세요', 'KO', '[an-nyeong-ha-se-yo]', '你好', '안녕하세요, 제 이름은 철수입니다.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1360, 14, '안녕', 'KO', '[an-nyeong]', '你好/再见 (非正式)', '안녕, 잘 지냈어?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1361, 14, '안녕히 가세요', 'KO', '[an-nyeong-hi ga-se-yo]', '再见 (客人走)', '안녕히 가세요, 다음에 또 오세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1362, 14, '안녕히 계세요', 'KO', '[an-nyeong-hi gye-se-yo]', '再见 (主人留)', '안녕히 계세요, 또 뵙겠습니다.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1363, 14, '감사합니다', 'KO', '[gam-sa-ham-ni-da]', '谢谢', '도와주셔서 감사합니다.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1364, 14, '고마워요', 'KO', '[go-ma-wo-yo]', '谢谢 (非正式)', '선물 고마워요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1365, 14, '네', 'KO', '[ne]', '是/嗯', '네, 알겠습니다.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1366, 14, '아니요', 'KO', '[a-ni-yo]', '不/不是', '아니요, 괜찮아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1367, 14, '죄송합니다', 'KO', '[joe-song-ham-ni-da]', '对不起/抱歉', '지각해서 죄송합니다.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1368, 14, '미안해요', 'KO', '[mi-an-hae-yo]', '对不起 (非正式)', '늦어서 미안해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1369, 14, '실례합니다', 'KO', '[sil-lye-ham-ni-da]', '打扰一下/失礼了', '실례합니다, 화장실이 어디예요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1370, 14, '천만에요', 'KO', '[cheon-man-e-yo]', '不客气', '천만에요, 언제든 도와드릴게요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1371, 14, '반갑습니다', 'KO', '[ban-gap-seum-ni-da]', '很高兴见到您', '처음 뵙겠습니다, 반갑습니다.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1372, 14, '안녕히 주무세요', 'KO', '[an-nyeong-hi ju-mu-se-yo]', '晚安', '오늘 하루도 고생 많으셨어요, 안녕히 주무세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1373, 14, '사랑해요', 'KO', '[sa-rang-hae-yo]', '我爱你', '진심으로 사랑해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1374, 14, '미워요', 'KO', '[mi-wo-yo]', '讨厌/恨你', '너무 화나서 미워요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1375, 14, '하나', 'KO', '[ha-na]', '一 (固有词)', '사과 하나 주세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1376, 14, '둘', 'KO', '[dul]', '二 (固有词)', '친구가 둘 있어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1377, 14, '셋', 'KO', '[set]', '三 (固有词)', '세 시에 만나요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1378, 14, '넷', 'KO', '[net]', '四 (固有词)', '네 명 예약했어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1379, 14, '다섯', 'KO', '[da-seot]', '五 (固有词)', '다섯 살이에요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1380, 14, '열', 'KO', '[yeol]', '十 (固有词)', '열 번 반복하세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1381, 14, '일', 'KO', '[il]', '一 (汉字词)', '일 월 일 일 (1月1日)', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1382, 14, '이', 'KO', '[i]', '二 (汉字词)', '이 층으로 가주세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1383, 14, '삼', 'KO', '[sam]', '三 (汉字词)', '삼 겹으로 되어 있어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1384, 14, '사', 'KO', '[sa]', '四 (汉字词)', '사 년생이에요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1385, 14, '오', 'KO', '[o]', '五 (汉字词)', '오 분만 기다려요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1386, 14, '육', 'KO', '[yuk]', '六 (汉字词)', '육 개 주세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1387, 14, '칠', 'KO', '[chil]', '七 (汉字词)', '칠 월이에요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1388, 14, '팔', 'KO', '[pal]', '八 (汉字词)', '팔 월 팔 일 (8月8日)', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1389, 14, '구', 'KO', '[gu]', '九 (汉字词)', '구 월 구 일 (9月9日)', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1390, 14, '십', 'KO', '[sip]', '十 (汉字词)', '십 원이에요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1391, 14, '백', 'KO', '[baek]', '百', '백 원 주세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1392, 14, '천', 'KO', '[cheon]', '千', '천 원이에요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1393, 14, '만', 'KO', '[man]', '万', '만 원짜리 지폐.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1394, 14, '오늘', 'KO', '[o-neul]', '今天', '오늘 날씨가 좋네요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1395, 14, '내일', 'KO', '[nae-il]', '明天', '내일 만나요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1396, 14, '모레', 'KO', '[mo-re]', '后天', '모레 다시 오세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1397, 14, '어제', 'KO', '[eo-je]', '昨天', '어제 영화 봤어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1398, 14, '그저께', 'KO', '[geu-jeo-kke]', '前天', '그저께 비가 왔어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1399, 14, '지금', 'KO', '[ji-geum]', '现在', '지금 몇 시예요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1400, 14, '나중', 'KO', '[na-jung]', '稍后/以后', '나중에 이야기해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1401, 14, '아침', 'KO', '[a-chim]', '早晨', '아침 식사는 드셨어요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1402, 14, '점심', 'KO', '[jeom-sim]', '中午/午餐', '점심 드세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1403, 14, '저녁', 'KO', '[jeo-nyeok]', '晚上/晚餐', '저녁에 시간 있어요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1404, 14, '밤', 'KO', '[bam]', '夜晚', '밤이 깊었어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1405, 14, '일주일', 'KO', '[il-ju-il]', '一周', '일주일에 한 번 운동해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1406, 14, '한달', 'KO', '[han-dal]', '一个月', '한달 뒤에 떠나요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1407, 14, '일년', 'KO', '[il-lyeon]', '一年', '일년 동안 공부해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1408, 14, '월요일', 'KO', '[wol-yo-il]', '星期一', '월요일에 출근해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1409, 14, '화요일', 'KO', '[hwa-yo-il]', '星期二', '화요일은 휴무예요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1410, 14, '수요일', 'KO', '[su-yo-il]', '星期三', '수요일에 만나요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1411, 14, '목요일', 'KO', '[mok-yo-il]', '星期四', '목요일이 지나면 금방 주말이네요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1412, 14, '금요일', 'KO', '[geum-yo-il]', '星期五', '금요일 저녁에 약속이 있어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1413, 14, '토요일', 'KO', '[to-yo-il]', '星期六', '토요일에 쇼핑 갈래요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1414, 14, '일요일', 'KO', '[il-yo-il]', '星期日', '일요일은 집에서 쉬어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1415, 14, '아버지', 'KO', '[a-beo-ji]', '父亲 (敬语)', '우리 아버지는 회사원이에요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1416, 14, '어머니', 'KO', '[eo-meo-ni]', '母亲 (敬语)', '어머니가 요리를 잘하세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1417, 14, '엄마', 'KO', '[eom-ma]', '妈妈 (口语)', '엄마, 나 왔어요!', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1418, 14, '아빠', 'KO', '[a-ppa]', '爸爸 (口语)', '아빠가 사 오신 선물.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1419, 14, '아들', 'KO', '[a-deul]', '儿子', '아들이 효자예요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1420, 14, '딸', 'KO', '[ttal]', '女儿', '예쁜 딸이 있어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1421, 14, '형', 'KO', '[hyeong]', '哥哥 (男称男)', '형이랑 농구해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1422, 14, '오빠', 'KO', '[op-pa]', '哥哥 (女称男)', '오빠가 노래를 잘해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1423, 14, '누나', 'KO', '[nu-na]', '姐姐 (男称女)', '누나가 예뻐요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1424, 14, '언니', 'KO', '[eon-ni]', '姐姐 (女称女)', '언니랑 같이 가요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1425, 14, '동생', 'KO', '[dong-saeng]', '弟弟/妹妹', '남동생이 있어요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1426, 14, '친구', 'KO', '[chin-gu]', '朋友', '제 친구예요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1427, 14, '남자', 'KO', '[nam-ja]', '男人/男子', '남자 친구가 있어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1428, 14, '여자', 'KO', '[yeo-ja]', '女人/女子', '여자 친구가 있어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1429, 14, '사람', 'KO', '[sa-ram]', '人', '좋은 사람이 많아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1430, 14, '집', 'KO', '[jip]', '家/房子', '집에 가요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1431, 14, '방', 'KO', '[bang]', '房间', '제 방은 2 층이에요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1432, 14, '화장실', 'KO', '[hwa-jang-sil]', '卫生间', '화장실이 어디 있어요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1433, 14, '부엌', 'KO', '[bu-eok]', '厨房', '부엌에서 밥을 해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1434, 14, '거실', 'KO', '[geo-sil]', '客厅', '거실에서 텔레비전을 봐요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1435, 14, '침대', 'KO', '[chim-dae]', '床', '침대에서 자요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1436, 14, '책상', 'KO', '[chaek-sang]', '书桌', '책상 위에 책이 있어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1437, 14, '의자', 'KO', '[ui-ja]', '椅子', '의자에 앉으세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1438, 14, '창문', 'KO', '[chang-mun]', '窗户', '창문을 여세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1439, 14, '문', 'KO', '[mun]', '门', '문을 닫으세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1440, 14, '열쇠', 'KO', '[yeol-soe]', '钥匙', '열쇠를 잃어버렸어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1441, 14, '회사', 'KO', '[hoe-sa]', '公司', '회사에 다녀요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1442, 14, '병원', 'KO', '[byeong-won]', '医院', '아파서 병원에 갔어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1443, 14, '은행', 'KO', '[eun-haeng]', '银行', '은행에 돈을 찾으러 가요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1444, 14, '마트', 'KO', '[ma-teu]', '超市/卖场', '마트에서 장을 봐요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1445, 14, '편의점', 'KO', '[pyeon-ui-jeom]', '便利店', '편의점에서 컵라면을 샀어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1446, 14, '역', 'KO', '[yeok]', '车站/站', '지하철 역이 가까워요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1447, 14, '공항', 'KO', '[gong-hang]', '机场', '공항에 마중 나가요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1448, 14, '한국', 'KO', '[han-guk]', '韩国', '한국어를 공부해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1449, 14, '중국', 'KO', '[jung-guk]', '中国', '중국 사람이에요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1450, 14, '미국', 'KO', '[mi-guk]', '美国', '미국에 가본 적 있어요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1451, 14, '일본', 'KO', '[il-bon]', '日本', '일본 여행 가요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1452, 14, '물', 'KO', '[mul]', '水', '물을 주세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1453, 14, '밥', 'KO', '[bap]', '饭/米饭', '밥을 먹었어요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1454, 14, '김치', 'KO', '[gim-chi]', '泡菜', '김치가 매워요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1455, 14, '빵', 'KO', '[ppang]', '面包', '빵을 사 왔어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1456, 14, '우유', 'KO', '[u-yu]', '牛奶', '아침에 우유를 마셔요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1457, 14, '커피', 'KO', '[keo-pi]', '咖啡', '커피 한 잔 해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1458, 14, '차', 'KO', '[cha]', '茶/车', '녹차를 좋아해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1459, 14, '사과', 'KO', '[sa-gwa]', '苹果', '사과가 맛있어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1460, 14, '고기', 'KO', '[go-gi]', '肉', '고기를 구워요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1461, 14, '생선', 'KO', '[saeng-seon]', '鱼', '생선을 좋아하지 않아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1462, 14, '채소', 'KO', '[chae-so]', '蔬菜', '채소를 많이 드세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1463, 14, '맛있어요', 'KO', '[ma-si-sseo-yo]', '好吃', '정말 맛있어요!', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1464, 14, '맛없어요', 'KO', '[mat-eop-seo-yo]', '不好吃', '오늘 음식이 맛없어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1465, 14, '크다', 'KO', '[keu-da]', '大', '집이 커요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1466, 14, '작다', 'KO', '[jak-da]', '小', '방이 작아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1467, 14, '길다', 'KO', '[gil-da]', '长/久', '머리가 길어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1468, 14, '짧다', 'KO', '[jjap-da]', '短', '치마가 짧아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1469, 14, '많다', 'KO', '[man-ta]', '多', '사람이 많아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1470, 14, '적다', 'KO', '[jeok-da]', '少', '돈이 적어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1471, 14, '비싸다', 'KO', '[bi-ssa-da]', '贵', '옷이 비싸요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1472, 14, '싸다', 'KO', '[ssa-da]', '便宜', '가격이 싸요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1473, 14, '좋다', 'KO', '[jot-da]', '好', '날씨가 좋아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1474, 14, '나쁘다', 'KO', '[na-ppeu-da]', '坏/不好', '성격이 나빠요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1475, 14, '예쁘다', 'KO', '[ye-ppeu-da]', '漂亮', '꽃이 예뻐요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1476, 14, '잘생기다', 'KO', '[jal-saeng-gi-da]', '帅气', '남자친구가 잘생겼어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1477, 14, '못생기다', 'KO', '[мот-saeng-gi-da]', '难看', '못생긴 건 아니에요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1478, 14, '덥다', 'KO', '[deop-da]', '热 (天气)', '여름은 더워요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1479, 14, '춥다', 'KO', '[chup-da]', '冷 (天气)', '겨울은 추워요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1480, 14, '뜨겁다', 'KO', '[tteu-geop-da]', '热 (物体)', '커피가 뜨거워요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1481, 14, '차갑다', 'KO', '[cha-gap-da]', '凉/冷 (物体)', '물이 차가워요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1482, 14, '배고프다', 'KO', '[bae-go-peu-da]', '饿', '배고파서 밥 먹어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1483, 14, '배부르다', 'KO', '[bae-bu-reu-da]', '饱', '배불러서 못 먹겠어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1484, 14, '피곤하다', 'KO', '[pi-gon-ha-da]', '累', '오늘 하루 피곤해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1485, 14, '아프다', 'KO', '[a-peu-da]', '痛/生病', '머리가 아파요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1486, 14, '바쁘다', 'KO', '[ba-ppeu-da]', '忙', '요즘 바빠요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1487, 14, '힘들다', 'KO', '[him-deul-da]', '辛苦/吃力', '일이 힘들어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1488, 14, '즐겁다', 'KO', '[jeul-geop-da]', '愉快', '여행이 즐거웠어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1489, 14, '슬프다', 'KO', '[seul-peu-da]', '悲伤', '슬픈 영화를 봤어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1490, 14, '행복하다', 'KO', '[haeng-bo-ka-da]', '幸福', '행복해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1491, 14, '공부하다', 'KO', '[gong-bu-ha-da]', '学习', '한국어를 공부해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1492, 14, '일하다', 'KO', '[i-ri-ha-da]', '工作', '열심히 일해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1493, 14, '먹다', 'KO', '[meok-da]', '吃', '점심을 먹어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1494, 14, '마시다', 'KO', '[ma-si-da]', '喝', '물을 마셔요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1495, 14, '자다', 'KO', '[ja-da]', '睡觉', '일찍 자요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1496, 14, '일어나다', 'KO', '[i-reo-na-da]', '起床/发生', '아침에 일찍 일어났어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1497, 14, '가다', 'KO', '[ga-da]', '去', '학교에 가요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1498, 14, '오다', 'KO', '[o-da]', '来', '집에 왔어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1499, 14, '보다', 'KO', '[bo-da]', '看', '영화를 봐요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1500, 14, '듣다', 'KO', '[deut-da]', '听', '음악을 들어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1501, 14, '말하다', 'KO', '[ma-ri-ha-da]', '说', '한국말로 말해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1502, 14, '읽다', 'KO', '[ilk-da]', '读', '신문을 읽어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1503, 14, '쓰다', 'KO', '[sseu-da]', '写/用', '펜으로 써요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1504, 14, '사다', 'KO', '[sa-da]', '买', '옷을 사요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1505, 14, '팔다', 'KO', '[pal-da]', '卖', '물건을 팔아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1506, 14, '주다', 'KO', '[ju-da]', '给', '선물을 줘요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1507, 14, '받다', 'KO', '[bat-da]', '收到', '편지를 받았어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1508, 14, '만나다', 'KO', '[man-na-da]', '见面', '친구를 만나요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1509, 14, '사랑하다', 'KO', '[sa-rang-ha-da]', '爱', '사랑해요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1510, 14, '미워하다', 'KO', '[mi-wo-ha-da]', '讨厌', '미워하지 마세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1511, 14, '기다리다', 'KO', '[gi-da-ri-da]', '等待', '잠시만 기다려 주세요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1512, 14, '찾다', 'KO', '[chat-da]', '寻找/找', '열쇠를 찾아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1513, 14, '알다', 'KO', '[al-da]', '知道', '잘 알아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1514, 14, '모르다', 'KO', '[mo-reu-da]', '不知道', '모르겠어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1515, 14, '하다', 'KO', '[ha-da]', '做', '뭘 해요?', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1516, 14, '놀다', 'KO', '[nol-da]', '玩', '친구랑 놀아요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1517, 14, '쉬다', 'KO', '[swi-da]', '休息', '좀 쉬어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1518, 14, '걷다', 'KO', '[geot-da]', '走', '공원에서 걸어요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1519, 14, '달리다', 'KO', '[dal-li-da]', '跑', '빨리 달려요.', 1, '2026-04-27 23:27:02', '2026-04-27 23:27:02');
INSERT INTO `word` VALUES (1520, 14, '타다', 'KO', '[ta-da]', '乘/坐', '버스를 타요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1521, 14, '내리다', 'KO', '[nae-ri-da]', '下 (车)', '다음 역에서 내려요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1522, 14, '열다', 'KO', '[yeol-da]', '打开', '문을 여세요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1523, 14, '닫다', 'KO', '[dap-da]', '关闭', '창문을 닫으세요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1524, 14, '입다', 'KO', '[ip-da]', '穿 (衣)', '옷을 예쁘게 입었어요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1525, 14, '벗다', 'KO', '[beot-da]', '脱', '신발을 벗으세요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1526, 14, '살다', 'KO', '[sal-da]', '生活/住', '서울에 살아요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1527, 14, '죽다', 'KO', '[juk-da]', '死', '그림이 죽었어요. (引申义)', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1528, 14, '보내다', 'KO', '[bo-nae-da]', '发送/度过', '편지를 보내요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1529, 14, '부르다', 'KO', '[bu-reu-da]', '叫/唱', '노래를 불러요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1530, 14, '웃다', 'KO', '[ut-da]', '笑', '왜 웃어요?', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1531, 14, '울다', 'KO', '[ul-da]', '哭', '아기가 울어요.', 1, '2026-04-27 23:27:03', '2026-04-27 23:27:03');
INSERT INTO `word` VALUES (1532, 2, 'abnormal', 'EN', '[æbˈnɔːrml]', '反常的，异常的', 'The weather has been abnormal for this time of year.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1533, 2, 'abolish', 'EN', '[əˈbɑːlɪʃ]', '废除，取消', 'The government plans to abolish the tax on luxury goods.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1534, 2, 'abrupt', 'EN', '[əˈbrʌpt]', '突然的，意外的', 'His abrupt departure upset everyone at the party.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1535, 2, 'absurd', 'EN', '[əbˈsɜːrd]', '荒谬的，可笑的', 'It is absurd to argue about such a trivial matter.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1536, 2, 'abundant', 'EN', '[əˈbʌndənt]', '丰富的，充裕的', 'The region is abundant in natural resources.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1537, 2, 'accessory', 'EN', '[əkˈsesəri]', '附件，配饰', 'She bought a new handbag and matching accessories.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1538, 2, 'accommodate', 'EN', '[əˈkɑːmədeɪt]', '容纳；使适应', 'The hotel can accommodate up to 500 guests.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1539, 2, 'accord', 'EN', '[əˈkɔːrd]', '协议，一致', 'The two countries signed a peace accord.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1540, 2, 'accountable', 'EN', '[əˈkaʊntəbl]', '有责任的，可解释的', 'Managers must be accountable for their decisions.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1541, 2, 'accumulate', 'EN', '[əˈkjuːmjəleɪt]', '积累，堆积', 'Dust had accumulated on the shelves.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1542, 2, 'accuse', 'EN', '[əˈkjuːz]', '指责，控告', 'He was accused of stealing company funds.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1543, 2, 'acquaint', 'EN', '[əˈkweɪnt]', '使熟悉，使了解', 'You need to acquaint yourself with the new rules.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1544, 2, 'acquire', 'EN', '[əˈkwaɪər]', '获得，学到', 'She has acquired a good knowledge of English.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1545, 2, 'acute', 'EN', '[əˈkjuːt]', '剧烈的；敏锐的', 'He suffers from acute back pain.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1546, 2, 'adapt', 'EN', '[əˈdæpt]', '适应；改编', 'The movie was adapted from a novel.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1547, 2, 'addict', 'EN', '[ˈædɪkt]', '使成瘾；入迷的人', 'He is addicted to computer games.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1548, 2, 'adhere', 'EN', '[ədˈhɪr]', '坚持；粘附', 'Members must adhere to the club rules.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1549, 2, 'adjacent', 'EN', '[əˈdʒeɪsnt]', '邻近的，毗连的', 'The bank is in the building adjacent to the post office.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1550, 2, 'adjoin', 'EN', '[əˈdʒɔɪn]', '邻近，毗连', 'The kitchen adjoins the dining room.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1551, 2, 'adjust', 'EN', '[əˈdʒʌst]', '调整，调节', 'You can adjust the height of the chair.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1552, 2, 'administer', 'EN', '[ədˈmɪnɪstər]', '管理，实施', 'The fund will be administered by a local charity.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1553, 2, 'adolescent', 'EN', '[ˌædəˈlesnt]', '青少年', 'The adolescent years can be difficult for parents.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1554, 2, 'advent', 'EN', '[ˈædvent]', '出现，到来', 'The advent of the internet changed our lives.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1555, 2, 'adverse', 'EN', '[ˈædvɜːrs]', '不利的，有害的', 'The drug has some adverse side effects.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1556, 2, 'advocate', 'EN', '[ˈædvəkeɪt]', '提倡，主张', 'Many experts advocate a reduction in sugar intake.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1557, 2, 'aesthetic', 'EN', '[esˈθetɪk]', '美学的，审美的', 'The design is simple but has aesthetic appeal.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1558, 2, 'affiliate', 'EN', '[əˈfɪlieɪt]', '使隶属；分公司', 'The club is affiliated to the national sports association.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1559, 2, 'affirm', 'EN', '[əˈfɜːrm]', '断言，证实', 'The court affirmed the decision of the lower court.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1560, 2, 'affluent', 'EN', '[ˈæfluənt]', '富裕的', 'They live in an affluent suburb of the city.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1561, 2, 'agenda', 'EN', '[əˈdʒendə]', '议程表，议事日程', 'Let\'s move on to the next item on the agenda.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1562, 2, 'aggravate', 'EN', '[ˈæɡrəveɪt]', '加重，恶化', 'Stress can aggravate existing health problems.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1563, 2, 'agitate', 'EN', '[ˈædʒɪteɪt]', '煽动，搅动', 'Protesters were agitating for political change.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1564, 2, 'alert', 'EN', '[əˈlɜːrt]', '警觉的；警报', 'The public should be alert to the dangers of fraud.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1565, 2, 'alleviate', 'EN', '[əˈliːvieɪt]', '减轻，缓和', 'This medicine should alleviate the pain.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1566, 2, 'allocate', 'EN', '[ˈæləkeɪt]', '分配，拨出', 'A sum of money has been allocated for the project.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1567, 2, 'allowance', 'EN', '[əˈlaʊəns]', '津贴，零用钱', 'Children receive a weekly allowance.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1568, 2, 'ally', 'EN', '[ˈælaɪ]', '同盟国；结盟', 'Britain was an ally of France in the war.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1569, 2, 'alongside', 'EN', '[əˌlɔːŋˈsaɪd]', '在旁边；与...同时', 'They worked alongside the experts.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1570, 2, 'alter', 'EN', '[ˈɔːltər]', '改变，更改', 'You need to alter your dress; it\'s too long.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1571, 2, 'alternate', 'EN', '[ɔːlˈtɜːrnət]', '交替的，轮流的', 'We work on alternate days.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1572, 2, 'amateur', 'EN', '[ˈæmətər]', '业余爱好者', 'He is an amateur photographer.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1573, 2, 'ambassador', 'EN', '[æmˈbæsədər]', '大使', 'The ambassador presented his credentials to the president.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1574, 2, 'ambiguous', 'EN', '[æmˈbɪɡjuəs]', '模棱两可的', 'His reply was ambiguous.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1575, 2, 'ambitious', 'EN', '[æmˈbɪʃəs]', '有雄心的，野心勃勃的', 'She is an ambitious young lawyer.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1576, 2, 'amend', 'EN', '[əˈmend]', '修正，改良', 'Congress voted to amend the law.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1577, 2, 'amiable', 'EN', '[ˈeɪmiəbl]', '和蔼可亲的，亲切的', 'He is an amiable old gentleman.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1578, 2, 'ample', 'EN', '[ˈæmpl]', '充足的，宽敞的', 'There is ample room for everyone.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1579, 2, 'amplify', 'EN', '[ˈæmplɪfaɪ]', '放大，增强', 'The microphone amplified his voice.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1580, 2, 'analogy', 'EN', '[əˈnælədʒi]', '类比，比拟', 'He drew an analogy between the brain and a computer.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1581, 2, 'analytic', 'EN', '[ˌænəˈlɪtɪk]', '分析的，解析的', 'She has an analytic mind.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1582, 2, 'angel', 'EN', '[ˈeɪndʒl]', '天使', 'She looks like an angel in that dress.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1583, 2, 'anonymous', 'EN', '[əˈnɑːnɪməs]', '匿名的', 'The donation was made by an anonymous donor.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1584, 2, 'antarctic', 'EN', '[ænˈtɑːrktɪk]', '南极的；南极洲', 'Antarctic ice is melting.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1585, 2, 'antique', 'EN', '[ænˈtiːk]', '古董，古老的', 'This vase is a genuine antique.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1586, 2, 'anxiety', 'EN', '[æŋˈzaɪəti]', '焦虑，担心', 'There is growing anxiety about the war.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1587, 2, 'apart', 'EN', '[əˈpɑːrt]', '分离，相隔', 'Take the engine apart.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1588, 2, 'ape', 'EN', '[eɪp]', '猿', 'Chimpanzees are a type of ape.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1589, 2, 'apparatus', 'EN', '[ˌæpəˈreɪtəs]', '器械，设备', 'The laboratory has modern apparatus.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1590, 2, 'appeal', 'EN', '[əˈpiːl]', '呼吁，上诉；吸引力', 'The idea of working abroad holds little appeal for me.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1591, 2, 'appendix', 'EN', '[əˈpendɪks]', '附录，阑尾', 'See the appendix for more details.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1592, 2, 'applaud', 'EN', '[əˈplɔːd]', '鼓掌，称赞', 'The audience applauded the performance.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1593, 2, 'appraisal', 'EN', '[əˈpreɪzl]', '评价，估价', 'He gave a fair appraisal of the situation.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1594, 2, 'appreciate', 'EN', '[əˈpriːʃieɪt]', '欣赏，感激；增值', 'I really appreciate your help.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1595, 2, 'apprehensive', 'EN', '[ˌæprɪˈhensɪv]', '忧虑的，担心的', 'She was apprehensive about the interview.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1596, 2, 'approach', 'EN', '[əˈproʊtʃ]', '接近，方法', 'Winter is approaching.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1597, 2, 'appropriate', 'EN', '[əˈproʊpriət]', '适当的；挪用', 'It is not appropriate to wear jeans to a wedding.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1598, 2, 'approximate', 'EN', '[əˈprɑːksɪmət]', '近似的，大约的', 'The approximate cost is $500.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1599, 2, 'aptitude', 'EN', '[ˈæptɪtuːd]', '天资，才能', 'He has a natural aptitude for music.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1600, 2, 'arbitrary', 'EN', '[ˈɑːrbətreri]', '任意的，武断的', 'The choice was completely arbitrary.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1601, 2, 'architect', 'EN', '[ˈɑːrkɪtekt]', '建筑师', 'The architect designed a beautiful building.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1602, 2, 'arctic', 'EN', '[ˈɑːrktɪk]', '北极的', 'Arctic explorers face harsh conditions.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1603, 2, 'arise', 'EN', '[əˈraɪz]', '出现，发生', 'Problems may arise during the project.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1604, 2, 'arouse', 'EN', '[əˈraʊz]', '引起，唤醒', 'The noise aroused me from sleep.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1605, 2, 'array', 'EN', '[əˈreɪ]', '排列，阵列；一系列', 'An array of products was on display.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1606, 2, 'articulate', 'EN', '[ɑːrˈtɪkjələt]', '表达清晰的', 'She is an articulate speaker.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1607, 2, 'ascend', 'EN', '[əˈsend]', '上升，攀登', 'The path ascends to the mountain top.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1608, 2, 'ascertain', 'EN', '[ˌæsərˈteɪn]', '查明，确定', 'Police are trying to ascertain the cause of the accident.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1609, 2, 'ascribe', 'EN', '[əˈskraɪb]', '归因于', 'He ascribed his success to hard work.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1610, 2, 'assault', 'EN', '[əˈsɔːlt]', '攻击，袭击', 'The soldier was killed in a surprise assault.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1611, 2, 'assemble', 'EN', '[əˈsembl]', '集合，装配', 'Students assembled in the hall.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1612, 2, 'assert', 'EN', '[əˈsɜːrt]', '断言，坚持主张', 'He asserted his innocence.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1613, 2, 'assess', 'EN', '[əˈses]', '评估，估价', 'It is difficult to assess the value of the painting.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1614, 2, 'asset', 'EN', '[ˈæset]', '资产，优点', 'Good health is a great asset.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1615, 2, 'assimilate', 'EN', '[əˈsɪməleɪt]', '吸收，同化', 'It takes time to assimilate into a new culture.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1616, 2, 'assist', 'EN', '[əˈsɪst]', '帮助，协助', 'She assisted him in his research.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1617, 2, 'associate', 'EN', '[əˈsoʊʃieɪt]', '联想，交往；同事', 'I don\'t want to be associated with this scandal.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1618, 2, 'assume', 'EN', '[əˈsuːm]', '假定，承担', 'I assume you know the answer.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1619, 2, 'assurance', 'EN', '[əˈʃʊrəns]', '保证，保险', 'He gave me an assurance that it would be ready by Friday.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1620, 2, 'astonish', 'EN', '[əˈstɑːnɪʃ]', '使惊讶', 'The news astonished everyone.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1621, 2, 'astronomy', 'EN', '[əˈstrɑːnəmi]', '天文学', 'He is studying astronomy at university.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1622, 2, 'athlete', 'EN', '[ˈæθliːt]', '运动员', 'He is a talented athlete.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1623, 2, 'atmosphere', 'EN', '[ˈætməsfɪr]', '大气，气氛', 'The atmosphere in the room was tense.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1624, 2, 'atom', 'EN', '[ˈætəm]', '原子', 'Everything is made of atoms.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1625, 2, 'attach', 'EN', '[əˈtætʃ]', '系上，贴上；使依恋', 'Please attach a photo to your application.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1626, 2, 'attain', 'EN', '[əˈteɪn]', '达到，获得', 'She attained the rank of director.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1627, 2, 'attempt', 'EN', '[əˈtempt]', '试图，尝试', 'He attempted to climb the mountain.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1628, 2, 'attend', 'EN', '[əˈtend]', '出席，照料', 'Did you attend the meeting?', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1629, 2, 'attendant', 'EN', '[əˈtendənt]', '服务员；随从', 'The parking lot attendant took my ticket.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1630, 2, 'attribute', 'EN', '[əˈtrɪbjuːt]', '属性；归因于', 'Kindness is one of his best attributes.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1631, 2, 'auction', 'EN', '[ˈɔːkʃn]', '拍卖', 'The painting was sold at auction.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1632, 2, 'audience', 'EN', '[ˈɔːdiəns]', '观众，听众', 'The audience cheered loudly.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1633, 2, 'authentic', 'EN', '[ɔːˈθentɪk]', '真实的，可信的', 'This is an authentic medieval manuscript.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1634, 2, 'authority', 'EN', '[əˈθɔːrəti]', '权威，权力；当局', 'The authorities have banned the protest.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1635, 2, 'automate', 'EN', '[ˈɔːtəmeɪt]', '使自动化', 'The factory was fully automated.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1636, 2, 'autonomous', 'EN', '[ɔːˈtɑːnəməs]', '自治的', 'The region became autonomous.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1637, 2, 'auxiliary', 'EN', '[ɔːɡˈzɪliəri]', '辅助的，备用的', 'An auxiliary generator provides power during outages.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1638, 2, 'avail', 'EN', '[əˈveɪl]', '效用，利益', 'He tried to fix the car but to no avail.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1639, 2, 'avert', 'EN', '[əˈvɜːrt]', '避免，转移', 'Disaster was averted by quick action.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1640, 2, 'aviation', 'EN', '[ˌeɪviˈeɪʃn]', '航空，飞行', 'He has a passion for aviation.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1641, 2, 'avoid', 'EN', '[əˈvɔɪd]', '避免', 'She tried to avoid answering the question.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1642, 2, 'await', 'EN', '[əˈweɪt]', '等候', 'We are awaiting your reply.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1643, 2, 'awake', 'EN', '[əˈweɪk]', '醒着的；唤醒', 'Stay awake during the lecture.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1644, 2, 'award', 'EN', '[əˈwɔːrd]', '奖品；授予', 'She won an award for her novel.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1645, 2, 'aware', 'EN', '[əˈwer]', '意识到的', 'Are you aware of the risks?', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1646, 2, 'awesome', 'EN', '[ˈɔːsəm]', '令人敬畏的；极好的', 'The view from the top was awesome.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1647, 2, 'awkward', 'EN', '[ˈɔːkwərd]', '尴尬的；笨拙的', 'There was an awkward silence.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1648, 2, 'bachelor', 'EN', '[ˈbætʃələr]', '学士；单身汉', 'He is a bachelor of arts.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1649, 2, 'bacteria', 'EN', '[bækˈtɪriə]', '细菌', 'Bacteria can cause disease.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1650, 2, 'badge', 'EN', '[bædʒ]', '徽章，证章', 'Police officers wear badges.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1651, 2, 'baffle', 'EN', '[ˈbæfl]', '使困惑', 'The question baffled the experts.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1652, 2, 'bald', 'EN', '[bɔːld]', '秃头的', 'He is going bald.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1653, 2, 'ballet', 'EN', '[ˈbæleɪ]', '芭蕾舞', 'She goes to ballet classes every week.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1654, 2, 'ban', 'EN', '[bæn]', '禁止，取缔', 'Smoking is banned in public places.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1655, 2, 'bandage', 'EN', '[ˈbændɪdʒ]', '绷带', 'He put a bandage on his cut finger.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1656, 2, 'bankrupt', 'EN', '[ˈbæŋkrʌpt]', '破产的', 'The company went bankrupt.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1657, 2, 'bare', 'EN', '[ber]', '赤裸的；仅仅的', 'He walked on the bare floor.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1658, 2, 'bargain', 'EN', '[ˈbɑːrɡən]', '交易；讨价还价', 'That car was a real bargain.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1659, 2, 'barren', 'EN', '[ˈbærən]', '贫瘠的；不育的', 'The land was barren and dry.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1660, 2, 'barrier', 'EN', '[ˈbæriər]', '障碍，屏障', 'Language is a barrier to communication.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1661, 2, 'batch', 'EN', '[bætʃ]', '一批，一组', 'A new batch of students arrived.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1662, 2, 'battery', 'EN', '[ˈbætəri]', '电池', 'The battery is dead.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1663, 2, 'beam', 'EN', '[biːm]', '横梁；光线', 'A beam of light shone through the window.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1664, 2, 'bearing', 'EN', '[ˈberɪŋ]', '关系；轴承；举止', 'His opinion has no bearing on the matter.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1665, 2, 'beforehand', 'EN', '[bɪˈfɔːrhænd]', '预先，事先', 'You should book tickets beforehand.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1666, 2, 'beware', 'EN', '[bɪˈwer]', '当心，谨防', 'Beware of the dog.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1667, 2, 'bewilder', 'EN', '[bɪˈwɪldər]', '使迷惑', 'The complex instructions bewildered me.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1668, 2, 'bias', 'EN', '[ˈbaɪəs]', '偏见，偏心', 'He has a bias against modern art.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1669, 2, 'bibliography', 'EN', '[ˌbɪbliˈɑːɡrəfi]', '参考书目', 'Check the bibliography for more sources.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1670, 2, 'bid', 'EN', '[bɪd]', '出价；投标', 'They made a bid for the company.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1671, 2, 'bizarre', 'EN', '[bɪˈzɑːr]', '奇异的', 'He has some bizarre habits.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1672, 2, 'blade', 'EN', '[bleɪd]', '刀刃，叶片', 'The blade of the knife is sharp.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1673, 2, 'blank', 'EN', '[blæŋk]', '空白的；茫然的', 'Fill in the blank spaces.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1674, 2, 'blast', 'EN', '[blæst]', '爆炸；一阵', 'A blast of wind blew the door open.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1675, 2, 'blaze', 'EN', '[bleɪz]', '火焰；燃烧', 'The fire blazed all night.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1676, 2, 'bleak', 'EN', '[bliːk]', '萧瑟的；无望的', 'The future looks bleak.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1677, 2, 'bless', 'EN', '[bles]', '祝福', 'God bless you.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1678, 2, 'block', 'EN', '[blɑːk]', '街区；块；阻碍', 'A block of ice blocked the road.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1679, 2, 'bloom', 'EN', '[bluːm]', '花；开花', 'The roses are in bloom.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1680, 2, 'blunder', 'EN', '[ˈblʌndər]', '大错，失误', 'Making that comment was a huge blunder.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1681, 2, 'blunt', 'EN', '[blʌnt]', '钝的；直率的', 'The knife is blunt.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1682, 2, 'blur', 'EN', '[blɜːr]', '模糊；污点', 'The lights blurred as I fell asleep.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1683, 2, 'blush', 'EN', '[blʌʃ]', '脸红', 'She blushed with embarrassment.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1684, 2, 'board', 'EN', '[bɔːrd]', '木板；董事会；上船', 'Get on board the train.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1685, 2, 'boast', 'EN', '[boʊst]', '自夸，吹嘘', 'He likes to boast about his wealth.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1686, 2, 'bold', 'EN', '[boʊld]', '大胆的，勇敢的', 'She was bold enough to ask for a raise.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1687, 2, 'bolt', 'EN', '[boʊlt]', '螺栓；门闩；逃跑', 'He shot the bolt on the door.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1688, 2, 'bond', 'EN', '[bɑːnd]', '纽带；债券；结合', 'There is a strong bond between them.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1689, 2, 'bonus', 'EN', '[ˈboʊnəs]', '奖金，红利', 'He received a Christmas bonus.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1690, 2, 'boom', 'EN', '[buːm]', '繁荣；隆隆声', 'The economy is booming.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1691, 2, 'boost', 'EN', '[buːst]', '推动，促进；提高', 'Publicity will boost sales.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1692, 2, 'booth', 'EN', '[buːθ]', '电话亭；摊位', 'Vote in the privacy of a booth.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1693, 2, 'border', 'EN', '[ˈbɔːrdər]', '边界，边境', 'They crossed the border into Mexico.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1694, 2, 'bore', 'EN', '[bɔːr]', '令人厌烦的人/事；钻孔', 'He gets bored easily.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1695, 2, 'bosom', 'EN', '[ˈbʊzəm]', '胸，胸怀', 'She held the baby to her bosom.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1696, 2, 'bother', 'EN', '[ˈbɑːðər]', '打扰，麻烦', 'Sorry to bother you.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1697, 2, 'bounce', 'EN', '[baʊns]', '弹跳，反弹', 'The ball bounced off the wall.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1698, 2, 'bound', 'EN', '[baʊnd]', '一定的；跳跃；边界', 'He is bound to succeed.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1699, 2, 'boundary', 'EN', '[ˈbaʊndri]', '分界线，边界', 'The fence marks the boundary.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1700, 2, 'bow', 'EN', '[boʊ]', '弓；鞠躬；船头', 'He took a bow at the end of the play.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1701, 2, 'boycott', 'EN', '[ˈbɔɪkɑːt]', '抵制', 'They decided to boycott the product.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1702, 2, 'brace', 'EN', '[breɪs]', '支撑；支架；使防备', 'Brace yourself for bad news.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1703, 2, 'bracket', 'EN', '[ˈbrækɪt]', '括号；支架', 'Put your name in brackets.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1704, 2, 'breakdown', 'EN', '[ˈbreɪkdaʊn]', '故障；崩溃；分解', 'The car had a breakdown.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1705, 2, 'breed', 'EN', '[briːd]', '品种；繁殖；养育', 'Rabbits breed quickly.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1706, 2, 'breeze', 'EN', '[briːz]', '微风', 'A cool breeze blew from the sea.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1707, 2, 'bribe', 'EN', '[braɪb]', '贿赂', 'He was accused of taking bribes.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1708, 2, 'brisk', 'EN', '[brɪsk]', '轻快的；兴隆的', 'We went for a brisk walk.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1709, 2, 'brittle', 'EN', '[ˈbrɪtl]', '易碎的，脆弱的', 'Old bones are brittle.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1710, 2, 'bronze', 'EN', '[brɑːnz]', '青铜；青铜色', 'The statue is made of bronze.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1711, 2, 'brook', 'EN', '[brʊk]', '小溪', 'We sat by the babbling brook.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1712, 2, 'browse', 'EN', '[braʊz]', '浏览，随意观看', 'I browsed through the magazines.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1713, 2, 'bruise', 'EN', '[bruːz]', '瘀伤，擦伤', 'He had a bruise on his arm.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1714, 2, 'brute', 'EN', '[bruːt]', '野兽；残忍的人', 'He acted like a brute.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1715, 2, 'bubble', 'EN', '[ˈbʌbl]', '气泡；冒泡', 'Soap bubbles floated in the air.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1716, 2, 'bucket', 'EN', '[ˈbʌkɪt]', '桶', 'He filled the bucket with water.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1717, 2, 'budget', 'EN', '[ˈbʌdʒɪt]', '预算', 'The government announced a new budget.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1718, 2, 'buffer', 'EN', '[ˈbʌfər]', '缓冲器；缓冲物', 'Trees act as a buffer against the wind.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1719, 2, 'bug', 'EN', '[bʌɡ]', '虫子；故障；窃听器', 'There is a bug in the software.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1720, 2, 'bulb', 'EN', '[bʌlb]', '灯泡；球茎', 'The light bulb has burned out.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1721, 2, 'bulk', 'EN', '[bʌlk]', '体积；大批；大部分', 'The bulk of the work is done.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1722, 2, 'bull', 'EN', '[bʊl]', '公牛', 'A bull charged at the matador.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1723, 2, 'bullet', 'EN', '[ˈbʊlɪt]', '子弹', 'The bullet missed him by inches.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1724, 2, 'bulletin', 'EN', '[ˈbʊlətɪn]', '公告，简报', 'News bulletins are broadcast every hour.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1725, 2, 'bump', 'EN', '[bʌmp]', '碰撞；肿块', 'He got a bump on his head.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1726, 2, 'bunch', 'EN', '[bʌntʃ]', '束，串；一群', 'A bunch of flowers.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1727, 2, 'bundle', 'EN', '[ˈbʌndl]', '捆，包，束', 'He carried a bundle of sticks.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1728, 2, 'burden', 'EN', '[ˈbɜːrdn]', '负担，重担', 'The tax burden is heavy.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1729, 2, 'bureau', 'EN', '[ˈbjʊroʊ]', '局，办事处，写字台', 'The travel bureau provides information.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1730, 2, 'burglar', 'EN', '[ˈbɜːrɡlər]', '窃贼，夜贼', 'The burglar broke in through the window.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1731, 2, 'burn', 'EN', '[bɜːrn]', '燃烧，烧伤', 'The fire burned for hours.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1732, 2, 'burst', 'EN', '[bɜːrst]', '爆炸，突发；爆裂', 'The balloon burst.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1733, 2, 'bury', 'EN', '[ˈberi]', '埋葬；掩藏', 'They buried the treasure.', 1, '2026-04-27 23:36:25', '2026-04-27 23:36:25');
INSERT INTO `word` VALUES (1734, 2, 'butcher', 'EN', '[ˈbʊtʃər]', '屠夫；屠杀', 'The butcher cut the meat.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1735, 2, 'butterfly', 'EN', '[ˈbʌtərflaɪ]', '蝴蝶', 'The butterfly landed on the flower.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1736, 2, 'button', 'EN', '[ˈbʌtn]', '纽扣；按钮', 'Press the red button.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1737, 2, 'bypass', 'EN', '[ˈbaɪpæs]', '旁路；绕过', 'We took a bypass to avoid the traffic.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1738, 2, 'cabinet', 'EN', '[ˈkæbɪnət]', '橱柜；内阁', 'The Prime Minister met with his cabinet.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1739, 2, 'cable', 'EN', '[ˈkeɪbl]', '电缆；电报；缆绳', 'Send a cablegram.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1740, 2, 'cafeteria', 'EN', '[ˌkæfəˈtɪriə]', '自助餐厅', 'Let\'s eat in the cafeteria.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1741, 2, 'calcium', 'EN', '[ˈkælsiəm]', '钙', 'Milk contains calcium.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1742, 2, 'calculate', 'EN', '[ˈkælkjuleɪt]', '计算，估算', 'We need to calculate the cost.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1743, 2, 'calendar', 'EN', '[ˈkælɪndər]', '日历', 'Check the date on the calendar.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1744, 2, 'calorie', 'EN', '[ˈkæləri]', '卡路里', 'This food is high in calories.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1745, 2, 'campus', 'EN', '[ˈkæmpəs]', '校园', 'He lives on the university campus.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1746, 2, 'canal', 'EN', '[kəˈnæl]', '运河，沟渠', 'The boat went through the Panama Canal.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1747, 2, 'cancel', 'EN', '[ˈkænsl]', '取消', 'The flight was cancelled due to fog.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1748, 2, 'cancer', 'EN', '[ˈkænsər]', '癌症', 'Smoking can cause lung cancer.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1749, 2, 'candidate', 'EN', '[ˈkændɪdət]', '候选人，申请人', 'There are three candidates for the job.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1750, 2, 'cane', 'EN', '[keɪn]', '手杖；茎', 'Sugar cane is used to make sugar.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1751, 2, 'canvas', 'EN', '[ˈkænvəs]', '帆布；油画布', 'The artist painted on canvas.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1752, 2, 'capable', 'EN', '[ˈkeɪpəbl]', '有能力的', 'She is capable of doing the job.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1753, 2, 'capacity', 'EN', '[kəˈpæsəti]', '容量；能力；身份', 'The stadium has a seating capacity of 50,000.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1754, 2, 'cape', 'EN', '[keɪp]', '海角；披肩', 'The ship rounded the Cape of Good Hope.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1755, 2, 'capsule', 'EN', '[ˈkæpsuːl]', '胶囊；太空舱', 'Swallow the capsule with water.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1756, 2, 'caption', 'EN', '[ˈkæpʃn]', '标题，说明文字', 'Read the caption under the picture.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1757, 2, 'captive', 'EN', '[ˈkæptɪv]', '俘虏；被监禁的', 'The animals are kept in captive conditions.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1758, 2, 'capture', 'EN', '[ˈkæptʃər]', '捕获，俘获；引起注意', 'The army captured the city.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1759, 2, 'carbohydrate', 'EN', '[ˌkɑːrboʊˈhaɪdreɪt]', '碳水化合物', 'Bread is rich in carbohydrates.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1760, 2, 'carbon', 'EN', '[ˈkɑːrbən]', '碳', 'Carbon dioxide is a greenhouse gas.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1761, 2, 'cardinal', 'EN', '[ˈkɑːrdɪnl]', '基本的，主要的；红衣主教', 'Honesty is a cardinal virtue.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1762, 2, 'cargo', 'EN', '[ˈkɑːrɡoʊ]', '货物', 'The ship is carrying a cargo of oil.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1763, 2, 'carpenter', 'EN', '[ˈkɑːrpəntər]', '木匠', 'The carpenter built a table.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1764, 2, 'carpet', 'EN', '[ˈkɑːrpɪt]', '地毯', 'We need to clean the carpet.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1765, 2, 'carriage', 'EN', '[ˈkærɪdʒ]', '马车；客车厢', 'A horse-drawn carriage.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1766, 2, 'carrier', 'EN', '[ˈkæriər]', '载体；运输公司', 'An aircraft carrier.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1767, 2, 'cart', 'EN', '[kɑːrt]', '手推车，大车', 'Push the shopping cart.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1768, 2, 'carve', 'EN', '[kɑːrv]', '刻，雕刻；切', 'He carved his name on the tree.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1769, 2, 'case', 'EN', '[keɪs]', '情况；案例；箱子', 'In that case, I will go.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1770, 2, 'cash', 'EN', '[kæʃ]', '现金', 'Pay in cash, please.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1771, 2, 'cashier', 'EN', '[kæˈʃɪr]', '出纳员', 'Ask the cashier for change.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1772, 2, 'cassette', 'EN', '[kəˈset]', '盒式磁带', 'Do you have any old cassettes?', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1773, 2, 'cast', 'EN', '[kæst]', '投，扔；演员阵容', 'The doctor put a cast on his leg.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1774, 2, 'casual', 'EN', '[ˈkæʒuəl]', '偶然的；随便的；临时的', 'Wear casual clothes to the party.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1775, 2, 'casualty', 'EN', '[ˈkæʒuəlti]', '伤亡人员；受害者', 'There were no casualties in the accident.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1776, 2, 'catalog', 'EN', '[ˈkætəlɔːɡ]', '目录；编目', 'Check the library catalog.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1777, 2, 'catastrophe', 'EN', '[kəˈtæstrəfi]', '大灾难', 'The earthquake was a catastrophe.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1778, 2, 'category', 'EN', '[ˈkætəɡɔːri]', '种类，范畴', 'Put the books into different categories.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1779, 2, 'cater', 'EN', '[ˈkeɪtər]', '迎合，提供饮食', 'The restaurant caters for vegetarians.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1780, 2, 'cathedral', 'EN', '[kəˈθiːdrəl]', '大教堂', 'The cathedral is very old.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1781, 2, 'Catholic', 'EN', '[ˈkæθlɪk]', '天主教的；天主教徒', 'She is a Catholic.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1782, 2, 'caution', 'EN', '[ˈkɔːʃn]', '小心，谨慎；警告', 'Use caution when driving.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1783, 2, 'cautious', 'EN', '[ˈkɔːʃəs]', '小心的，谨慎的', 'Be cautious of strangers.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1784, 2, 'cavity', 'EN', '[ˈkævəti]', '洞，穴；龋齿', 'The dentist filled the cavity in my tooth.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1785, 2, 'cease', 'EN', '[siːs]', '停止，终止', 'The fighting ceased at midnight.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1786, 2, 'ceiling', 'EN', '[ˈsiːlɪŋ]', '天花板', 'The ceiling is very high.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1787, 2, 'celebrate', 'EN', '[ˈselɪbreɪt]', '庆祝', 'We celebrated his birthday.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1788, 2, 'celebrity', 'EN', '[səˈlebrəti]', '名人，名流', 'He is a television celebrity.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1789, 2, 'cell', 'EN', '[sel]', '细胞；牢房；电池', 'A plant cell.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1790, 2, 'cellar', 'EN', '[ˈselər]', '地窖，地下室', 'Keep the wine in the cellar.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1791, 2, 'census', 'EN', '[ˈsensəs]', '人口普查', 'The census is taken every ten years.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1792, 2, 'centigrade', 'EN', '[ˈsentɪɡreɪd]', '摄氏的', 'Water boils at 100 degrees centigrade.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1793, 2, 'centimetre', 'EN', '[ˈsentɪmiːtər]', '厘米', 'The line is ten centimetres long.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1794, 2, 'central', 'EN', '[ˈsentrəl]', '中心的，中央的', 'The central station is busy.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1795, 2, 'century', 'EN', '[ˈsentʃəri]', '世纪，百年', 'We live in the 21st century.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1796, 2, 'ceramic', 'EN', '[səˈræmɪk]', '陶瓷的；陶瓷制品', 'Ceramic tiles are easy to clean.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1797, 2, 'cereal', 'EN', '[ˈsɪriəl]', '谷类植物；谷物食品', 'Eat a bowl of cereal for breakfast.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1798, 2, 'ceremony', 'EN', '[ˈserəmoʊni]', '典礼，仪式', 'The graduation ceremony was held yesterday.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1799, 2, 'certain', 'EN', '[ˈsɜːrtn]', '确定的；某，某些', 'I am certain of it.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1800, 2, 'certainty', 'EN', '[ˈsɜːrtnti]', '必然的事；确定', 'Nothing is certain in this world.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1801, 2, 'certificate', 'EN', '[sərˈtɪfɪkət]', '证书，证明书', 'A birth certificate.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1802, 2, 'certify', 'EN', '[ˈsɜːrtɪfaɪ]', '证明，证实', 'The document was certified as true.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1803, 2, 'chain', 'EN', '[tʃeɪn]', '链条；连锁', 'He put a chain on the dog.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1804, 2, 'chairman', 'EN', '[ˈtʃermən]', '主席，会长', 'The chairman opened the meeting.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1805, 2, 'challenge', 'EN', '[ˈtʃælɪndʒ]', '挑战；质疑', 'Climbing the mountain was a challenge.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1806, 2, 'chamber', 'EN', '[ˈtʃeɪmbər]', '房间，室；议院', 'The gas chamber.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1807, 2, 'champion', 'EN', '[ˈtʃæmpiən]', '冠军，拥护者', 'He is the world boxing champion.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1808, 2, 'chance', 'EN', '[tʃæns]', '机会，可能性；偶然', 'Take a chance.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1809, 2, 'channel', 'EN', '[ˈtʃænl]', '频道；渠道；海峡', 'Change the channel, please.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1810, 2, 'chaos', 'EN', '[ˈkeɪɑːs]', '混乱，紊乱', 'After the storm, there was chaos.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1811, 2, 'chapter', 'EN', '[ˈtʃæptər]', '章，回，篇', 'Read chapter one.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1812, 2, 'character', 'EN', '[ˈkærəktər]', '性格；角色；汉字', 'He has a strong character.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1813, 2, 'characteristic', 'EN', '[ˌkærəktəˈrɪstɪk]', '特征，特性；特有的', 'Green is the characteristic colour of grass.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1814, 2, 'characterize', 'EN', '[ˈkærəktəraɪz]', '表现...的特色，刻画的...性格', 'Electricity is characterized by a high degree of versatility.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1815, 2, 'charge', 'EN', '[tʃɑːrdʒ]', '费用；控告；充电', 'How much do you charge?', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1816, 2, 'charity', 'EN', '[ˈtʃærəti]', '慈善；施舍；慈善团体', 'Give money to charity.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1817, 2, 'charm', 'EN', '[tʃɑːrm]', '魅力；迷人', 'She has a charming personality.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1818, 2, 'charter', 'EN', '[ˈtʃɑːrtər]', '宪章；特许；包租', 'The UN charter.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1819, 2, 'chase', 'EN', '[tʃeɪs]', '追逐，追赶', 'The dog chased the cat.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1820, 2, 'chat', 'EN', '[tʃæt]', '聊天，闲谈', 'We had a nice chat.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1821, 2, 'cheap', 'EN', '[tʃiːp]', '便宜的，廉价的', 'These shoes are cheap.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1822, 2, 'cheat', 'EN', '[tʃiːt]', '欺骗，作弊', 'He cheated in the exam.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1823, 2, 'check', 'EN', '[tʃek]', '检查；支票；制止', 'Check your work carefully.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1824, 2, 'cheek', 'EN', '[tʃiːk]', '面颊，脸蛋', 'She kissed him on the cheek.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1825, 2, 'cheer', 'EN', '[tʃɪr]', '欢呼，喝彩；使振奋', 'Cheer up! Things will get better.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1826, 2, 'cheese', 'EN', '[tʃiːz]', '奶酪，干酪', 'Do you like cheese?', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1827, 2, 'chef', 'EN', '[ʃef]', '厨师，主厨', 'The chef cooked a delicious meal.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1828, 2, 'chemical', 'EN', '[ˈkemɪkl]', '化学的；化学品', 'Chemical reactions occur.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1829, 2, 'chemist', 'EN', '[ˈkemɪst]', '化学家；药剂师', 'He is a research chemist.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1830, 2, 'chemistry', 'EN', '[ˈkemɪstri]', '化学', 'Chemistry is a branch of science.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1831, 2, 'cheque', 'EN', '[tʃek]', '支票 (英式)', 'Write a cheque for $100.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1832, 2, 'cherish', 'EN', '[ˈtʃerɪʃ]', '珍爱，怀有', 'She cherishes the memory of those days.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1833, 2, 'cherry', 'EN', '[ˈtʃeri]', '樱桃，樱桃树', 'I like eating cherries.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1834, 2, 'chess', 'EN', '[tʃes]', '国际象棋', 'Do you play chess?', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1835, 2, 'chest', 'EN', '[tʃest]', '胸腔，箱子', 'He has a pain in his chest.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1836, 2, 'chew', 'EN', '[tʃuː]', '咀嚼', 'Chew your food well.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1837, 2, 'chief', 'EN', '[tʃiːf]', '主要的；首领', 'The chief reason for failure.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1838, 2, 'childhood', 'EN', '[ˈtʃaɪldhʊd]', '童年，幼年', 'He had a happy childhood.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1839, 2, 'chill', 'EN', '[tʃɪl]', '寒冷，寒意；使变冷', 'There is a chill in the air.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1840, 2, 'chimney', 'EN', '[ˈtʃɪmni]', '烟囱', 'Smoke came out of the chimney.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1841, 2, 'chin', 'EN', '[tʃɪn]', '下巴', 'He rested his chin on his hand.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1842, 2, 'chip', 'EN', '[tʃɪp]', '碎片；芯片；炸薯条', 'A computer chip.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1843, 2, 'chocolate', 'EN', '[ˈtʃɑːklət]', '巧克力', 'I love chocolate.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1844, 2, 'choice', 'EN', '[tʃɔɪs]', '选择，抉择；供选择的东西', 'You have a choice.', 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');
INSERT INTO `word` VALUES (1845, 2, 'choke', 'EN', '[tʃoʊk]', '窒息', NULL, 1, '2026-04-27 23:36:26', '2026-04-27 23:36:26');

-- ----------------------------
-- Table structure for word_bank
-- ----------------------------
DROP TABLE IF EXISTS `word_bank`;
CREATE TABLE `word_bank`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '创建者ID（逻辑外键，关联user.id）',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '词库名称',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '词库描述',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '词库分类：四级/六级/考研/自定义',
  `language` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'EN' COMMENT '学习语种：EN/JA/KO',
  `word_count` int NOT NULL DEFAULT 0 COMMENT '单词数量',
  `is_public` tinyint NOT NULL DEFAULT 0 COMMENT '是否公开：0-私有，1-待审核，2-已公开',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-正常，0-禁用/删除',
  `version` int NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_is_public`(`is_public` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE,
  INDEX `idx_language`(`language` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '词库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of word_bank
-- ----------------------------
INSERT INTO `word_bank` VALUES (1, 1, '四级核心词汇', '大学英语四级核心词汇（示例数据，可继续批量导入）', '四级', 'EN', 260, 2, 1, 1, '2026-04-14 13:05:41', '2026-04-25 11:57:47');
INSERT INTO `word_bank` VALUES (2, 1, '六级核心词汇', '大学英语六级核心词汇（示例数据，可继续批量导入）', '六级', 'EN', 317, 2, 1, 0, '2026-04-14 13:05:41', '2026-04-27 23:36:25');
INSERT INTO `word_bank` VALUES (3, 1, '考研核心词汇', '考研英语核心词汇（示例数据，可继续批量导入）', '考研', 'EN', 229, 2, 1, 0, '2026-04-14 13:05:41', '2026-04-21 21:40:11');
INSERT INTO `word_bank` VALUES (4, 2, '计算机专业词汇', '计算机相关专业英语词汇', '自定义', 'EN', 2, 0, 1, 0, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word_bank` VALUES (5, 2, '日常英语词汇', '日常英语常用词汇', '自定义', 'EN', 2, 0, 1, 0, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word_bank` VALUES (6, 3, '商务英语词汇', '商务场景英语词汇', '自定义', 'EN', 2, 0, 1, 0, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word_bank` VALUES (13, 1, '日语入门词库', '日语基础高频词（示例数据）', '日语', 'JA', 185, 2, 1, 1, '2026-04-18 23:28:09', '2026-04-18 23:28:09');
INSERT INTO `word_bank` VALUES (14, 1, '韩语入门词库', '韩语基础高频词（示例数据）', '韩语', 'KO', 173, 2, 1, 0, '2026-04-18 23:28:09', '2026-04-27 23:27:12');
INSERT INTO `word_bank` VALUES (23, 1, '德语入门', NULL, '德语入门', 'DE', 159, 2, 1, 0, '2026-04-27 19:12:35', '2026-04-27 19:31:42');
INSERT INTO `word_bank` VALUES (24, 1, '法语入门', NULL, '法语入门', 'FR', 171, 2, 1, 0, '2026-04-27 22:45:53', '2026-04-27 22:48:28');
INSERT INTO `word_bank` VALUES (25, 1, '西班牙语入门', NULL, '西班牙语入门', 'ES', 210, 2, 1, 0, '2026-04-27 23:14:08', '2026-04-27 23:17:47');

-- ----------------------------
-- Table structure for word_bank_collect
-- ----------------------------
DROP TABLE IF EXISTS `word_bank_collect`;
CREATE TABLE `word_bank_collect`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID（逻辑外键，关联user.id）',
  `word_bank_id` bigint NOT NULL COMMENT '词库ID（逻辑外键，关联word_bank.id）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1-已收藏，0-已取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_user_id_word_bank_id`(`user_id` ASC, `word_bank_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '词库收藏表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of word_bank_collect
-- ----------------------------
INSERT INTO `word_bank_collect` VALUES (1, 2, 3, 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word_bank_collect` VALUES (2, 3, 1, 1, '2026-04-14 13:05:41', '2026-04-14 13:05:41');
INSERT INTO `word_bank_collect` VALUES (3, 30, 2, 0, '2026-04-15 11:02:07', '2026-04-15 11:08:00');
INSERT INTO `word_bank_collect` VALUES (4, 30, 3, 1, '2026-04-15 11:07:55', '2026-04-15 17:44:26');
INSERT INTO `word_bank_collect` VALUES (5, 5, 3, 0, '2026-04-15 22:38:14', '2026-04-15 22:40:52');
INSERT INTO `word_bank_collect` VALUES (6, 35, 12, 1, '2026-04-19 20:37:50', '2026-04-19 20:37:50');
INSERT INTO `word_bank_collect` VALUES (7, 39, 1, 1, '2026-04-23 13:36:37', '2026-04-23 13:36:37');
INSERT INTO `word_bank_collect` VALUES (8, 43, 3, 0, '2026-04-25 10:55:07', '2026-04-25 10:55:13');
INSERT INTO `word_bank_collect` VALUES (9, 46, 1, 1, '2026-04-25 11:55:26', '2026-04-25 11:55:26');

SET FOREIGN_KEY_CHECKS = 1;
