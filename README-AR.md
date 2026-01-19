<p align="center">
  <a href="https://bazzite.gg/"><img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/></a>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml) [![build-bazzite-isos](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml) [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ublue-os/bazzite) [![LFX Health Score](https://insights.linuxfoundation.org/api/badge/health-score?project=ublue-os-bazzite)](https://insights.linuxfoundation.org/project/ublue-os-bazzite) [![LFX Active Contributors](https://insights.linuxfoundation.org/api/badge/active-contributors?project=ublue-os-bazzite)](https://insights.linuxfoundation.org/project/ublue-os-bazzite)

# [](https://github.com/ublue-os/bazzite/blob/main/README.md) [](https://github.com/ublue-os/bazzite/blob/main/README-SPA.md) [](https://github.com/ublue-os/bazzite/blob/main/README-ID.md) [](https://github.com/ublue-os/bazzite/blob/main/README-zh-cn.md) [](https://github.com/ublue-os/bazzite/blob/main/README-FR.md) [](https://github.com/ublue-os/bazzite/blob/main/README-BR.md) [](https://github.com/ublue-os/bazzite/blob/main/README-NL.md) [](https://github.com/ublue-os/bazzite/blob/main/README-RU.md) [](https://github.com/ublue-os/bazzite/blob/main/README-DE.md)

<p align="center">
  <a href="https://download.bazzite.gg/"><img src="/repo_content/download.png?raw=true" alt="تنزيل Bazzite"/></a>
</p>

---

# جدول المحتويات
- [        ](#--------)
- [جدول المحتويات](#table-of-contents)
  - [حول والميزات](#about--features)
    - [سطح المكتب](#desktop)
    - [Steam Deck/أجهزة المسرح المنزلي (HTPCs)](#steam-deckhome-theater-pcs-htpcs)
      - [أجهزة محمولة بديلة](#alternative-handhelds)
    - [جنوم](#gnome)
    - [ميزات من المصدر الأعلى](#features-from-upstream)
      - [Universal Blue](#universal-blue)
      - [ميزات من فيدورا لينكس (Kinoite & Silverblue)](#features-from-fedora-linux-kinoite--silverblue)
  - [لماذا](#why)
  - [العرض](#showcase)
  - [التوثيق](#documentation)
  - [التحقق](#verification)
  - [الإقلاع الآمن](#secure-boot)
  - [مقاييس المساهمين](#contributor-metrics)
  - [تاريخ النجوم](#star-history)
  - [شكر خاص](#special-thanks)
  - [أنشئ نسختك الخاصة](#build-your-own)
  - [انضم إلى المجتمع](#join-the-community)
---

## حول والميزات

[يرجى الاطلاع على موقعنا](https://bazzite.gg/) لشرح مناسب للمبتدئين حول Bazzite. هذا الملف يوضح كل شيء بالتفصيل.

[Bazzite](https://bazzite.gg/) هي صورة مخصصة من [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) مبنية باستخدام تقنيات [سحابية أصلية](https://universal-blue.org/#cloud-native) تجلب أفضل تجربة ألعاب لينكس إلى جميع أجهزتك  بما في ذلك جهازك المحمول المفضل.

Bazzite مبنية من [ublue-os/main](https://github.com/ublue-os/main) و[ublue-os/nvidia](https://github.com/ublue-os/nvidia) باستخدام تقنيات [Fedora](https://fedoraproject.org/) ما يعني دعما موسعا للأجهزة وتضمين التعريفات المدمجة. بالإضافة إلى ذلك تضيف Bazzite الميزات التالية:

- تستخدم [نواة bazzite](https://github.com/bazzite-org/kernel-bazzite) لتحقيق HDR ودعم موسع للأجهزة إلى جانب العديد من التصحيحات الأخرى  مبنية على [نواة fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/).
- HDR متاح في وضع اللعب.
- NVK متاح في إصدارات غير Nvidia.
- دعم كامل لتسريع العتاد لترميز H264 في فك التشفير.
- دعم كامل لبيئات التشغيل OpenCL/HIP من AMD (ROCM).
- تعريف [xone](https://github.com/medusalix/xone) لوحدات تحكم Xbox.
- دعم كامل لـ[DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- تتضمن ثيمات KDE من Valve في SteamOS.
- تثبيت افتراضي لكل من [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX) [vkBasalt](https://github.com/DadSchoorse/vkBasalt) [MangoHud](https://github.com/flightlessmango/Mangohud) و[OBS VkCapture](https://github.com/nowrep/obs-vkcapture) ومتاح استخدامها مباشرة.
- [Switcheroo-Control المعدل](https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/) لإصلاح تبديل iGPU/dGPU المعطل افتراضيا.
- تضمين امتداد الصدفة [ROM Properties Page](https://github.com/GerbilSoft/rom-properties).
- دعم كامل لـ[Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) مثبت مسبقا.
- تبسيط تثبيت Davinci Resolve عبر [davincibox](https://github.com/zelikos/davincibox) (`ujust install-resolve`).
- استخدام [Ptyxis Terminal](https://gitlab.gnome.org/chergert/ptyxis) كافتراضي في جميع الصور. هذا الطرفية مصممة خصيصا لسير عمل الحاويات الذي ستستخدمه في Bazzite. يمكن تثبيت KDE Konsole وGNOME Console كـ Flatpaks عند الحاجة.
- خدمة `duperemove` المؤتمتة لتقليل مساحة القرص المستخدمة بواسطة محتويات wine prefix.
- دعم HDMI CEC عبر [libCEC](https://libcec.pulse-eight.com/).
- استخدام [تحكم الازدحام TCP BBR من Google](https://github.com/google/bbr) افتراضيا.
- [Input Remapper](https://github.com/sezanzeb/input-remapper) مثبت وممكن. <sub><sup>(متاح لكنه معطل افتراضيا على إصدار Deck ويمكن تمكينه عبر `ujust restore-input-remapper`)</sup></sub>
- يوفر Bazzite Portal طريقة سهلة لتثبيت العديد من التطبيقات والتعديلات بما في ذلك تثبيت [LACT](https://github.com/ilya-zlobintsev/LACT).
- [Waydroid](https://waydro.id/) مثبت مسبقا لتشغيل تطبيقات أندرويد. قم بإعداده عبر هذا [الدليل السريع](https://docs.bazzite.gg/Installing_and_Managing_Software/Waydroid_Setup_Guide/).
- إدارة التطبيقات باستخدام [Flatseal](https://github.com/tchx84/Flatseal) [Warehouse](https://github.com/flattool/warehouse) و[Gear Lever](https://github.com/mijorus/gearlever).
- تعريفات [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) i2c-piix4 وi2c-nct6775 للتحكم في RGB على بعض اللوحات الأم.
- تعريفات [OpenRazer](https://openrazer.github.io) مدمجة اختر OpenRazer في Bazzite Portal أو شغل `ujust install-openrazer` في الطرفية للبدء.
- قواعد udev لـ[OpenTabletDriver](https://opentabletdriver.net/) مدمجة مع إمكانية تثبيت المجموعة البرمجية الكاملة عبر Bazzite Portal أو عبر `ujust install-opentabletdriver` في الطرفية.
- دعم جاهز لأجهزة لوحات مفاتيح [Wooting](https://wooting.io/).
- دعم مدمج لبطاقات AMD Southern Islands <sub><sup>(HD 7000)</sup></sub> وSea Islands <sub><sup>(HD 8000)</sup></sub> تحت تعريف `amdgpu`.
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) متاح لمشاركة شاشة Discord على Wayland.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) متاح لإنشاء تطبيقات من مواقع الويب لمجموعة متنوعة من المتصفحات بما في ذلك Firefox.

### سطح المكتب

النسخة العامة المتاحة باسم `bazzite` مناسبة لأجهزة الكمبيوتر المكتبية.

- تحديثات تلقائية للنظام وFlatpaks وغيرها  تعتمد على [ublue-update](https://github.com/ublue-os/ublue-update) و[topgrade](https://github.com/topgrade-rs/topgrade).

> [!IMPORTANT]
> **يمكن تنزيل ملفات ISO من [موقعنا](https://download.bazzite.gg) ويمكن العثور على دليل تثبيت مفيد [هنا](https://docs.bazzite.gg/General/Installation_Guide/).**

إعادة الارتكاز (rebase) من صورة Fedora Atomic أصلية إلى هذه الصورة إذا كنت تريد **تعريفات GPU مفتوحة المصدر**:
(يرجى الملاحظة: خيار Mesa المفتوح المصدر لبطاقات NVIDIA NVK ما يزال عرضة للأخطاء وقت كتابة هذه السطور لأي مشاكل تتعلق بـ NVK [يرجى تقديم تقرير إلى Mesa]([url](https://docs.mesa3d.org/bugs.html)) وليس إلى Ublue/Bazzite)

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```

أو للأجهزة ببطاقات Nvidia التي ترغب في **تعريفات NVIDIA الاحتكارية**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```

**للمستخدمين الذين لديهم الإقلاع الآمن ممكنا:** اتبع [وثائق الإقلاع الآمن](#secure-boot) قبل إعادة الارتكاز.

### Steam Deck/أجهزة المسرح المنزلي (HTPCs)
نسخة مصممة للاستخدام كبديل لـ SteamOS على Steam Deck ولتجربة تشبه وحدة الألعاب على أجهزة HTPCs متاحة باسم `bazzite-deck`:

- الإقلاع مباشرة إلى وضع اللعب بما يطابق سلوك SteamOS.
- **`duperemove` التلقائي يقلل بشكل كبير من حجم compatdata.**
- **أحدث إصدار من Mesa ينشئ مخازن تظليل أصغر ولا يحتاجها لمنع التقطيع.**
- **يمكن الإقلاع حتى إذا كان القرص ممتلئا.**
- **دعم لكل لغة مدعومة من Fedora العليا.**
- **استخدام Wayland على سطح المكتب مع [دعم لإدخال Steam](https://github.com/Supreeeme/extest).**
- يتضمن [HHD](https://github.com/hhd-dev/hhd) لتوسيع دعم الإدخال على الأجهزة المحمولة غير التابعة لـ Valve.
- ميزات نقلت لمعظم حزم SteamOS بما في ذلك التعريفات وأدوات تحديث Firmware ووحدات التحكم بالمراوح [من مستودع evlaV](https://gitlab.com/evlaV).
- Mesa معدلة للتحكم الصحيح بمعدل الإطارات من Gamescope.
- تأتي مع تصحيحات من [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) لدعم كامل لـ BTRFS لبطاقة SD بشكل افتراضي.
- تشحن بنسخة منقولة من [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU) ممكنة افتراضيا.
- خيار لتثبيت [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader) [EmuDeck](https://www.emudeck.com/) [RetroDECK](https://retrodeck.net/) و[ProtonUp-Qt](https://davidotek.github.io/protonup-qt/) إلى جانب العديد من الحزم المفيدة الأخرى أثناء التثبيت.
- نظام تحديث مخصص يسمح بتحديث النظام وFlatpaks وغيرها مباشرة من واجهة وضع اللعب يعتمد على [ublue-update](https://github.com/ublue-os/ublue-update) و[topgrade](https://github.com/topgrade-rs/topgrade).
- دعم مدمج للإقلاع المزدوج مع ويندوز بفضل ترك تثبيت GRUB من Fedora كما هو.
- هل تسبب التحديث بعطل يمكنك الرجوع بسهولة إلى النسخة السابقة من Bazzite بفضل خاصية rollback في `rpm-ostree`. يمكنك حتى اختيار صور سابقة عند الإقلاع.
- Steam وLutris مثبتان مسبقا كحزم مكدسة (layered packages).
- [Discover Overlay](https://github.com/trigg/Discover) الخاص بـ Discord مثبت مسبقا ويتم تشغيله تلقائيا في وضع اللعب وعلى سطح المكتب إذا كان Discord مثبتا. [اطلع على الوثائق الرسمية هنا](https://trigg.github.io/Discover/bazzite).
- استخدام ZRAM<sub><sup>(4GB)</sup></sub> بخوارزمية الضغط LZ4 افتراضيا.
- جداول المعالج [LAVD](https://crates.io/crates/scx_lavd) و[BORE](https://github.com/firelzrd/bore-scheduler) لألعاب سلسة واستجابة عالية.
- جدول I/O Kyber لمنع تجويع الإدخال/الإخراج أثناء تثبيت الألعاب أو خلال عملية `duperemove` في الخلفية.
- تطبيق معاملات نواة SteamOS.
- ملفات معايرة الألوان لشاشات Steam Deck غير اللامعة والعاكسة مضمنة.
- ميزات افتراضيا معطلة لمستخدمي الخبرة تشمل:
    - خدمة لكسر السرعة الآمن منخفض المخاطر لـ Steam Deck وكذلك لأجهزة AMD Framework Laptops عبر [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) و[Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu) راجع `ryzenadj.service` و`/etc/default/ryzenadj`.
    - دعم مدمج لرفع تردد الشاشة. على سبيل المثال أضف `CUSTOM_REFRESH_RATES=30-68` إلى `/etc/environment`. معدلات التحديث الدنيا والقصوى تختلف حسب الجهاز المحمول!
    - عدلت RAM إلى 32GB على Steam Deck استمتع بضعف الحد الأقصى لـ VRAM يطبق تلقائيا. <sup><sub>(هل تشاركنا مهاراتك في اللحام)</sub></sup>
- يمكن تعطيل الخدمات الخاصة بعتاد Steam Deck عبر تشغيل `ujust disable-bios-updates` و`ujust disable-firmware-updates` في الطرفية. يتم تعطيلها تلقائيا على الأجهزة غير Deck وعلى Decks ذات شاشات DeckHD أو تعديلات RAM إلى 32GB.
- مزيد من المعلومات يمكن العثور عليها [هنا](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Steam_Gaming_Mode/) حول صور Bazzite الخاصة بـ Steam Deck.

> [!IMPORTANT]
> **يمكن تنزيل ملفات ISO من [موقعنا](https://download.bazzite.gg) ويمكن العثور على دليل تثبيت مفيد [هنا](https://docs.bazzite.gg/General/Installation_Guide/).**

إعادة الارتكاز من صورة Fedora Atomic أصلية إلى هذه الصورة:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### أجهزة محمولة بديلة

يرجى الرجوع إلى [ويكي الأجهزة المحمولة](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Handheld_Wiki/) للتغييرات المطلوبة في الإعدادات وإضافات Decky Loader لوضع Steam Gaming في جهازك المحمول المحدد.

**تأكد أيضا من قراءة [وثائق hhd](https://github.com/hhd-dev/hhd#after-install) بعض الأجهزة المحمولة تتطلب تغييرات/تحسينات محددة لتعمل بشكل صحيح.**

نشحن أيضا بأوامر `ujust` لتثبيت ثيمات [CSS Loader](https://docs.deckthemes.com/CSSLoader/Install/#linux-or-steam-deck) المختلفة التي لا يمكن العثور عليها في متجر CSS Loader. سيتم تحديثها تلقائيا مع Bazzite إذا كانت مثبتة.
```bash
# تثبيت ثيم Handheld Controller (https://github.com/victor-borges/handheld-controller-glyphs)
ujust install-hhd-controller-glyph-theme
```

### جنوم

إصدارات بسطح مكتب جنوم متاحة بنكهتي سطح المكتب وdeck. تأتي هذه الإصدارات مع الميزات الإضافية التالية:

- [تمكين دعم معدل التحديث المتغير والتدرج الكسري تحت Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- قائمة مخصصة في الشريط العلوي للعودة إلى وضع اللعب تشغيل Steam وفتح عدد من الأدوات المفيدة.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) مثبت وجاهز للاستخدام.
- تضمين امتداد [Hanabi](https://github.com/jeffshee/gnome-ext-hanabi) لتقديم ميزات مشابهة لـ Wallpaper Engine في KDE.
- العديد من الامتدادات الاختيارية مثبتة مسبقا بما في ذلك [إصلاحات مهمة لتجربة المستخدم](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- تحديثات تلقائية لثيم [Firefox GNOME](https://github.com/rafaelmardojai/firefox-gnome-theme) و[ثيم Thunderbird GNOME](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(إذا كانت مثبتة)</sub></sup>

> [!IMPORTANT]
> **يمكن تنزيل ملفات ISO من [موقعنا](https://download.bazzite.gg) ويمكن العثور على دليل تثبيت مفيد [هنا](https://docs.bazzite.gg/General/Installation_Guide/).**

إعادة الارتكاز من نظام ostree قائم إلى هذه الصورة:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

لإعادة الارتكاز إلى بيئة سطح مكتب مع **إصدار تعريفات NVIDIA الاحتكارية**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

لإعادة الارتكاز إلى **إصدار Steam Deck/HTPC**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

**للمستخدمين الذين لديهم الإقلاع الآمن ممكنا:** اتبع [وثائق الإقلاع الآمن](#secure-boot) قبل إعادة الارتكاز.

### ميزات من المصدر الأعلى

#### Universal Blue

- تعريفات Nvidia الاحتكارية مثبتة مسبقا. <sub><sup>(فقط لإصدارات Nvidia)</sup></sub>
- تم تمكين Flathub افتراضيا.
- أوامر [`ujust`](https://github.com/casey/just) للراحة.
- ترميزات وسائط متعددة جاهزة خارج الصندوق.
- إمكانية الرجوع (rollback) عن Bazzite من أي بناء خلال آخر 90 يوما.

#### ميزات من فيدورا لينكس (Kinoite & Silverblue)

- قاعدة قوية ومستقرة للغاية.
- حزم النظام تبقى محدثة نسبيا.
- إمكانية تكديس (layer) حزم Fedora إلى الصورة دون فقدانها بين التحديثات.
- تركيز على الأمان مع [SELinux](https://github.com/SELinuxProject/selinux) مثبت ومهيأ خارج الصندوق.
- القدرة على إعادة الارتكاز إلى صور Fedora Atomic مختلفة إذا رغبت دون فقدان بيانات المستخدم.
- دعم الطباعة بفضل [CUPS](https://www.cups.org/) المثبت مسبقا.

## لماذا

بدأت Bazzite كمشروع لحل بعض المشاكل التي تصيب SteamOS خاصة الحزم القديمة (رغم قاعدة Arch) وغياب مدير حزم وظيفي.

على الرغم من أن هذا المشروع أيضا قائم على الصور (image-based) إلا أنك تستطيع تثبيت أي حزمة من Fedora مباشرة من سطر الأوامر. ستستمر هذه الحزم عبر التحديثات <sub><sup>(لذا امض قدما وثبت برنامج الـ VPN الغامض الذي أمضيت ساعة تحاول تشغيله على SteamOS)</sup></sub>. بالإضافة إلى ذلك يتم تحديث Bazzite عدة مرات أسبوعيا بحزم من Fedora الأعلى لتمنحك أفضل أداء وأحدث الميزات  كلها على قاعدة مستقرة.

تشحن Bazzite بأحدث نواة لينكس وSELinux ممكن افتراضيا مع دعم كامل للإقلاع الآمن <sub><sup>(شغل `ujust enroll-secure-boot-key` وأدخل كلمة المرور `universalblue` إذا تم طلبها لتسجيل مفتاحنا)</sup></sub> وتشفير القرص ما يجعلها حلا منطقيا للحوسبة العامة. <sup><sub>(نعم يمكنك الطباعة من Bazzite)</sub></sup>

اقرأ [الأسئلة الشائعة](https://docs.bazzite.gg/General/FAQ/) للتفاصيل حول ما يميز Bazzite عن أنظمة لينكس الأخرى.

## العرض

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "ثيم KDE Vapor")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "ثيم KDE VGUI2")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "وضع اللعب في Steam")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "طرفيات Distrobox")
![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "ثيم GNOME Vapor")
![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "ثيم GNOME VGUI2")

## التوثيق

- [تثبيت وإدارة التطبيقات](https://docs.bazzite.gg/Installing_and_Managing_Software/)
- [التحديثات الرجوع وإعادة الارتكاز](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/)
- [دليل الألعاب](https://docs.bazzite.gg/Gaming/)

اطلع على [توثيق إضافي](http://docs.bazzite.gg/) حول المشروع.

## التحقق

هذه الصور موقعة باستخدام [cosign](https://docs.sigstore.dev/cosign/key_management/overview/) التابعة لـ sigstore. يمكنك التحقق من التوقيع بتنزيل مفتاح `cosign.pub` من هذا المستودع وتشغيل الأمر التالي:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## الإقلاع الآمن

> [!WARNING]
> **مستخدمي Steam Deck: لا يأتي Steam Deck مع تمكين الإقلاع الآمن ولا يشحن مع أي مفاتيح مسجلة افتراضيا. لا تقم بتمكينه إلا إذا كنت تعلم تماما ما تفعله.**

يدعم الإقلاع الآمن باستخدام مفتاحنا المخصص. يمكن العثور على المفتاح العام في جذر هذا المستودع [هنا](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der).
إذا رغبت في تسجيل هذا المفتاح قبل التثبيت أو إعادة الارتكاز نزل المفتاح وشغل ما يلي:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

للمستخدمين الموجودين بالفعل على صورة Universal Blue يمكنك بدلا من ذلك تشغيل `ujust enroll-secure-boot-key`.

إذا طلبت كلمة مرور استخدم `universalblue`.

## مقاييس المساهمين

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "صورة تحليلات Repobeats")

## تاريخ النجوم

<a href="https://star-history.com/#ublue-os/bazzite&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
  </picture>
</a>

## شكر خاص

Bazzite جهد مجتمعي ولن توجد دون دعم الجميع. فيما يلي بعض الأشخاص الذين ساعدونا على طول الطريق:

- [amelia.svg](https://bsky.app/profile/ameliasvg.bsky.social)  لابتكار شعارنا وهوية علامتنا.
- [SuperRiderTH](https://github.com/SuperRiderTH)  لابتكار فيديو بدء وضع اللعب في Steam.
- [evlaV](https://gitlab.com/evlaV)  لجعل كود Valve متاحا ولأنه [هذا الشخص](https://xkcd.com/2347/).
- [ChimeraOS](https://chimeraos.org/)  من أجل gamescope-session والدعم القيم على طول الطريق.
- [Jovian-NixOS](https://github.com/Jovian-Experiments)  لدعمنا في القضايا التقنية ولابتكار مشروع مماثل. حقا اطلع عليه. إنه ابن عمنا القائم على Nix.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/)  للمساعدة في تصحيحات النواة المطلوبة ولإنشاء [مستودع kernel-fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) الذي نستخدمه الآن.
- [nicknamenamenick](https://github.com/nicknamenamenick)  لكونه MVP حافظ تقريبا بمفرده على توثيقنا وأدبيات الدعم ولحالات لا تحصى من مساعدة المستخدمين.
- [Steam Deck Homebrew](https://deckbrew.xyz)  لاختيار دعم توزيعات أخرى غير SteamOS بالرغم من العمل الإضافي وشكر خاص لـ [PartyWumpus](https://github.com/PartyWumpus) لجعل Decky Loader يعمل مع SELinux لنا.
- [cyrv6737](https://github.com/cyrv6737)  للإلهام الأولي والقاعدة التي أصبحت bazzite-arch.

## أنشئ نسختك الخاصة

يتم بناء Bazzite بالكامل على GitHub وإنشاء نسختك المخصصة منه سهل مثل عمل fork لهذا المستودع إضافة مفتاح توقيع خاص وتمكين GitHub Actions.

[تعرف](https://docs.github.com/en/actions/security-guides/encrypted-secrets) على الحفاظ على الأسرار في GitHub. ستحتاج إلى [إنشاء زوج مفاتيح جديد](https://docs.sigstore.dev/cosign/signing/overview/) باستخدام cosign. يمكن أن يكون المفتاح العام في مستودعك العام <sub><sup>(يحتاجه المستخدمون للتحقق من التوقيعات)</sup></sub> ويمكنك لصق المفتاح الخاص في `Settings -> Secrets -> Actions` باسم `SIGNING_SECRET`.

نشحن أيضا بإعداد لتطبيق [pull](https://github.com/apps/pull) الشائع إذا رغبت في إبقاء fork خاصتك متزامنا مع المصدر. فعل هذا التطبيق على مستودعك لتتبع تغييرات Bazzite أثناء قيامك بتعديلاتك الخاصة.

## انضم إلى المجتمع

- ستجدنا على [Universal Blue Discord](https://discord.gg/f8MUghG5PB)
  - اعرض [الأرشيف](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769) لمواضيع الدعم دون حساب.

- ناقش وأنشئ أدلة المستخدم في [منتديات Universal Blue Discourse](https://universal-blue.discourse.group/c/bazzite/5).

- تابع Universal Blue على [Mastodon](https://fosstodon.org/@UniversalBlue).

[**اطلع على القائمة الكاملة لموارد Bazzite والحضور الاجتماعي**](https://docs.bazzite.gg/Resources/).
