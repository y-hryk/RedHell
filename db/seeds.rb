# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
Menu.create([{ name: '牛タンあぶり葱まぶし定食', price: 1480, kind_id: 1 },
             { name: '長崎直送 お刺身定食', price: 1500, kind_id: 1  },
             { name: 'ネキトロ丼と鴨葱つけ汁うどんセット', price: 1230, kind_id: 1  },
             { name: '名物 牛バラ牛すじすき焼き定食', price: 1080, kind_id: 1  },
             { name: '豚バラ野菜せいろ蒸し定食', price: 1100, kind_id: 1  },
             { name: '地鶏の唐揚げ定食', price: 1000, kind_id: 1  },
             { name: '秋刀魚の蒲焼き丼', price: 1000, kind_id: 1  },
             { name: '塩麻雜スープのパクチー牛バラ石鍋定食', price: 1380, kind_id: 1  },
             { name: '生姜スープの鶏野菜石鍋定食', price: 1000, kind_id: 1  },
             { name: '赤地獄スープの豚野菜石鍋定食<とろろ付き>', price: 1000, kind_id: 1  },
             { name: '野菜たっぷり豆乳煮込みうどん', price: 1000, kind_id: 1  },
             { name: '牛バラとろろ煮込みうどん', price: 1000, kind_id: 1  },
             
             { name: 'おかか納豆', price: 150, kind_id: 1  },
             { name: 'とろろ', price: 180, kind_id: 1  },
             { name: '生玉子', price: 80, kind_id: 1  },
             ])
Kind.create(name: 'lunch')
Kind.create(name: 'dinner')
