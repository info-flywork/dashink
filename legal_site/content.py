"""Dashink yasal metinleri (TR + EN). Uygulamanın ve dashink-backend'in
gerçekte işlediği verilere göre yazılmıştır: anonim cihaz hesabı (ad / e-posta
yok), oyun ilerlemesi, sıralama, görevler, RevenueCat ile dashink_premium
(non-consumable); reklam, analitik ve uygulamalar arası takip yoktur.
Yerel bildirimler isteğe bağlıdır."""

EMAIL = '<a href="mailto:support@fly-work.com">support@fly-work.com</a>'

# ───────────────────────────── GİZLİLİK ─────────────────────────────

PRIVACY_TR = f"""
<div class="note">Dashink, yuvarlanan topun önüne mürekkep çizgisi çizdiğin bir arcade oyunudur. Senden
<strong>ad, e-posta veya telefon numarası istemeyiz</strong>, verilerini <strong>satmayız</strong>, uygulamada
<strong>reklam yoktur</strong> ve seni uygulamalar arasında <strong>takip etmeyiz</strong>. Bu politika, hangi verileri
neden işlediğimizi ve haklarını açıklar (6698 sayılı KVKK ve AB Genel Veri Koruma Tüzüğü – GDPR).</div>

<h2>1. Veri sorumlusu</h2>
<p>Dashink uygulaması ("Uygulama") Fly Work tarafından geliştirilir ve işletilir. Kişisel verilerinle ilgili tüm talepler
için: {EMAIL}</p>

<h2>2. Topladığımız veriler</h2>
<h3>2.1 Anonim oyuncu hesabı</h3>
<ul>
<li>Uygulamayı ilk açtığında cihazında rastgele bir <strong>cihaz kimliği</strong> oluşturulur ve sunucumuzda buna bağlı anonim
bir oyuncu hesabı açılır. Hesap açmak, giriş yapmak veya kişisel bilgi vermek gerekmez.</li>
<li>Oyuncu hesabına rastgele bir kullanıcı kimliği ve otomatik üretilen bir görünen ad (ör. "Oyuncu 4821") atanır; bu ad
iletişim bilgini içermez.</li>
</ul>
<h3>2.2 Oyun ilerlemesi</h3>
<p>Coin bakiyen, en iyi skorun, oynadığın oyun sayısı, tutorial durumu, kuşanılmış top / mürekkep / tema, sahip olduğun
öğeler, günlük ve haftalık skorların, görev ilerlemelerin ve coin hareketlerinin kaydı (oyun ödülü, görev, mağaza, premium
bonusu, günlük sıra ödülü).</p>
<h3>2.3 Sıralama</h3>
<p>Günlük, haftalık ve tüm zamanlar sıralamasında otomatik üretilen görünen adın ve skorun diğer oyunculara gösterilir. Ad,
e-posta veya fotoğraf paylaşılmaz.</p>
<h3>2.4 Satın alma bilgileri</h3>
<p>Dashink Premium satın aldığında: ürün, işlem kimliği, işlem tarihi ve ortamı (gerçek / test) ile premium durumu ve bir
kez verilen bonus coin. Ödeme App Store veya Google Play tarafından alınır; kart veya ödeme bilgilerini
<strong>görmeyiz</strong>.</p>
<h3>2.5 Paylaşım olayları</h3>
<p>Skor klipini cihazının paylaşım sayfasıyla dışarı gönderdiğinde yalnızca "paylaşım yapıldı" olayını (görev ilerlemesi
için) kaydederiz. Video veya görsel dosyası sunucumuza <strong>yüklenmez</strong>.</p>
<h3>2.6 Teknik veriler</h3>
<ul>
<li>Platform (iOS / Android) ve dil tercihi.</li>
<li>Güvenlik ve kötüye kullanımı önleme amaçlı sunucu istek kayıtları (IP adresi dahil).</li>
</ul>
<p>Konum, rehber, kamera rulosuna erişim (yalnızca sen paylaşım yaptığında cihazın kendi paylaşım sayfası kullanılır),
mikrofon, sağlık verisi veya tarama geçmişi <strong>toplamayız</strong>. Uygulamada analitik, reklam veya hata izleme SDK'sı
<strong>bulunmaz</strong>.</p>

<h2>3. Verileri neden ve hangi hukuki sebeple işliyoruz</h2>
<div class="table"><table>
<tr><th>Amaç</th><th>Hukuki sebep</th></tr>
<tr><td>Oyuncu hesabını oluşturmak, oturumunu yönetmek, oyunu çalıştırmak</td><td>Sözleşmenin kurulması ve ifası</td></tr>
<tr><td>İlerlemeni, coin bakiyeni, öğelerini ve görevlerini saklamak</td><td>Sözleşmenin ifası</td></tr>
<tr><td>Skor doğrulama, sıralama ve günlük / haftalık ödüller</td><td>Sözleşmenin ifası</td></tr>
<tr><td>Premium satın almayı doğrulamak, açmak; iade edilen işlemlerde geri almak</td><td>Sözleşmenin ifası</td></tr>
<tr><td>İsteğe bağlı yerel hatırlatma bildirimleri</td><td>Sözleşmenin ifası; istediğin zaman kapatabilirsin</td></tr>
<tr><td>Güvenlik, hile ve kötüye kullanımı önleme, hata giderme</td><td>Meşru menfaat</td></tr>
<tr><td>Yasal yükümlülükler (ör. ticari kayıtlar)</td><td>Kanuni yükümlülük</td></tr>
</table></div>
<p>Verilerini reklam, profil çıkarma veya pazarlama amacıyla <strong>kullanmayız</strong>.</p>

<h2>4. Verilerin aktarıldığı taraflar</h2>
<p>Verilerini <strong>satmayız</strong> ve reklam ağlarıyla <strong>paylaşmayız</strong>. Yalnızca bizim adımıza çalışan
hizmet sağlayıcılarla, gereken en az veriyi paylaşırız:</p>
<div class="table"><table>
<tr><th>Hizmet sağlayıcı</th><th>Veri</th><th>Konum</th></tr>
<tr><td>Barındırma (sunucu ve veritabanı)</td><td>Oyuncu hesabı, ilerleme ve satın alma kayıtları</td><td>Avrupa Birliği</td></tr>
<tr><td>RevenueCat</td><td>Anonim kullanıcı kimliği ve satın alma işlemleri (ad veya e-posta gönderilmez)</td><td>ABD</td></tr>
<tr><td>Apple / Google</td><td>Uygulama mağazası satın alma işlemleri</td><td>Global</td></tr>
</table></div>
<p>Sıralamada otomatik görünen adın ve skorun diğer oyunculara gösterilir. Ayrıca yasal bir zorunluluk veya yetkili makam
talebi olduğunda veri paylaşabiliriz.</p>

<h2>5. Yurt dışına aktarım</h2>
<p>RevenueCat ve uygulama mağazaları Türkiye ve Avrupa Ekonomik Alanı dışında (özellikle ABD) bulunabilir. Bu aktarımları KVKK ve
GDPR'ın öngördüğü güvencelerle (standart sözleşme hükümleri ve ilgili bildirimler) yaparız.</p>

<h2>6. Saklama süreleri</h2>
<div class="table"><table>
<tr><th>Veri</th><th>Süre</th></tr>
<tr><td>Oyuncu hesabı ve ilerleme</td><td>Hesap kullanıldığı sürece</td></tr>
<tr><td>Satın alma ve coin hareketi kayıtları</td><td>Yasal saklama süreleri boyunca (ticari kayıt yükümlülükleri)</td></tr>
<tr><td>Veri silme talebinden sonra</td><td>Oyun verileri makul süre içinde silinir; satın alma kayıtları anonim olarak yasal süre boyunca saklanır</td></tr>
<tr><td>Sunucu istek kayıtları</td><td>30 gün</td></tr>
</table></div>

<h2>7. Hakların</h2>
<p>KVKK m.11 ve GDPR kapsamında; verilerinin işlenip işlenmediğini öğrenme, bilgi ve kopya talep etme, düzeltme, silme,
işlemeyi kısıtlama ve itiraz etme ve verilerin taşınması hakların vardır.</p>
<ul>
<li><strong>Verilerini silme:</strong> {EMAIL} adresine "Dashink veri silme" konulu e-posta gönder. İlerlemen, coin'lerin,
öğelerin ve oturum bilgilerin sunucumuzdan silinir; RevenueCat'teki anonim müşteri kaydın da kaldırılır. Yasal saklama
yükümlülüğü olan satın alma işlem kayıtları, hiçbir cihaza veya kişiye bağlanamayacak şekilde ayrılarak saklanır. Hesabını
bulabilmemiz için mümkünse uygulama sürümünü ve cihaz platformunu (iOS / Android) yaz.</li>
<li><strong>Diğer talepler</strong> (bilgi, kopya, itiraz): {EMAIL}. Talebini en geç 30 gün içinde yanıtlarız.</li>
<li>Kişisel Verileri Koruma Kurulu'na veya bulunduğun ülkedeki veri koruma otoritesine şikâyette bulunma hakkın saklıdır.</li>
</ul>

<h2>8. Çocuklar</h2>
<p>Dashink her yaştan oyuncuya uygun bir arcade oyunudur ve ad, e-posta veya iletişim bilgisi istemez. 13 yaşından küçük
çocuklardan bilerek kişisel bilgi toplamayız; oyun yalnızca çalışması için gereken anonim kimliği kullanır. Uygulama içi satın
almalar için ebeveynlerin cihazdaki satın alma kısıtlamalarını (ör. "Satın Almak İçin Sor") kullanmasını öneririz. Bir çocuğa ait
veri işlediğimizi düşünüyorsan {EMAIL} adresinden bildir; ilgili verileri sileriz. Ayrıca
<a href="../csae/">Çocuk Güvenliği Standartları (CSAE)</a> sayfamıza bak.</p>

<h2>9. Güvenlik</h2>
<p>Veriler aktarım sırasında TLS ile şifrelenir; oturum anahtarları cihazın güvenli deposunda tutulur ve sunucu erişimi yetkiyle
sınırlıdır. Hiçbir sistem yüzde yüz güvenli olmasa da verilerini korumak için makul teknik ve idari önlemleri alırız.</p>

<h2>10. Bildirimler</h2>
<p>Günlük hatırlatma bildirimleri isteğe bağlıdır; cihaz izni ve uygulamadaki <em>Ayarlar</em> üzerinden istediğin zaman
kapatabilirsin. Bildirimler cihazda yerel olarak zamanlanır; push bildirim servisi kullanılmaz.</p>

<h2>11. Değişiklikler</h2>
<p>Bu politikayı güncelleyebiliriz. Önemli değişikliklerde uygulama içinde seni bilgilendiririz. Güncel sürüm her zaman bu
sayfadadır.</p>

<h2>12. İletişim</h2>
<p>Sorular ve talepler için: {EMAIL}</p>
"""

PRIVACY_EN = f"""
<div class="note">Dashink is an arcade game where you draw ink lines in front of a rolling ball. We <strong>do not ask for
your name, email or phone number</strong>, we <strong>do not sell</strong> your data, the app has <strong>no ads</strong> and we
<strong>do not track</strong> you across apps. This policy explains what data we process, why, and your rights (Turkish Personal
Data Protection Law No. 6698 – KVKK and the EU General Data Protection Regulation – GDPR).</div>

<h2>1. Data controller</h2>
<p>The Dashink app (the "App") is developed and operated by Fly Work. For any request regarding your personal data:
{EMAIL}</p>

<h2>2. Data we collect</h2>
<h3>2.1 Anonymous player account</h3>
<ul>
<li>When you first open the App, a random <strong>device identifier</strong> is created on your device and an anonymous player
account linked to it is opened on our server. You don't need to sign up, log in or provide personal information.</li>
<li>The player account gets a random user ID and an auto-generated display name (e.g. "Player 4821"); it does not contain your
contact details.</li>
</ul>
<h3>2.2 Game progress</h3>
<p>Your coin balance, best score, games played, tutorial status, equipped ball / ink / theme, owned items, daily and weekly
scores, task progress, and a record of coin changes (game rewards, tasks, shop, premium bonus, daily rank rewards).</p>
<h3>2.3 Leaderboards</h3>
<p>On daily, weekly and all-time leaderboards your auto-generated display name and score are shown to other players. No email or
photo is shared.</p>
<h3>2.4 Purchase information</h3>
<p>When you buy Dashink Premium: the product, transaction ID, transaction date and environment (production / test), premium
status and the one-time bonus coins. Payment is processed by the App Store or Google Play; we <strong>never see</strong> your card
or payment details.</p>
<h3>2.5 Share events</h3>
<p>When you share a score clip via your device's share sheet we only record that a share happened (for task progress). The video
or image file is <strong>not</strong> uploaded to our servers.</p>
<h3>2.6 Technical data</h3>
<ul>
<li>Platform (iOS / Android) and language preference.</li>
<li>Server request logs (including IP address) for security and abuse prevention.</li>
</ul>
<p>We <strong>do not collect</strong> location, contacts, photo library access (except when you yourself use the device share
sheet), microphone, health data or browsing history. The App contains <strong>no</strong> analytics, advertising or crash-tracking
SDKs.</p>

<h2>3. Why we process data and on what legal basis</h2>
<div class="table"><table>
<tr><th>Purpose</th><th>Legal basis</th></tr>
<tr><td>Creating your player account, managing your session, running the game</td><td>Performance of a contract</td></tr>
<tr><td>Storing your progress, coin balance, items and tasks</td><td>Performance of a contract</td></tr>
<tr><td>Score validation, leaderboards and daily / weekly rewards</td><td>Performance of a contract</td></tr>
<tr><td>Verifying and unlocking Premium; reversing refunded transactions</td><td>Performance of a contract</td></tr>
<tr><td>Optional local reminder notifications</td><td>Performance of a contract; you can turn them off anytime</td></tr>
<tr><td>Security, cheat and abuse prevention, debugging</td><td>Legitimate interest</td></tr>
<tr><td>Legal obligations (e.g. commercial records)</td><td>Legal obligation</td></tr>
</table></div>
<p>We <strong>do not use</strong> your data for advertising, profiling or marketing.</p>

<h2>4. Who we share data with</h2>
<p>We <strong>do not sell</strong> your data and <strong>do not share</strong> it with ad networks. We share only the minimum
necessary data with service providers acting on our behalf:</p>
<div class="table"><table>
<tr><th>Provider</th><th>Data</th><th>Location</th></tr>
<tr><td>Hosting (server and database)</td><td>Player account, progress and purchase records</td><td>European Union</td></tr>
<tr><td>RevenueCat</td><td>Anonymous user ID and purchase transactions (no name or email)</td><td>USA</td></tr>
<tr><td>Apple / Google</td><td>App store purchase transactions</td><td>Global</td></tr>
</table></div>
<p>Your auto-generated display name and score appear on leaderboards for other players. We may also disclose data where required
by law or a competent authority.</p>

<h2>5. International transfers</h2>
<p>RevenueCat and the app stores may be located outside Türkiye and the European Economic Area (notably in the USA). We carry out
these transfers with the safeguards required by KVKK and GDPR (standard contractual clauses and related notifications).</p>

<h2>6. Retention</h2>
<div class="table"><table>
<tr><th>Data</th><th>Period</th></tr>
<tr><td>Player account and progress</td><td>As long as the account is in use</td></tr>
<tr><td>Purchase and coin transaction records</td><td>For statutory retention periods (commercial record obligations)</td></tr>
<tr><td>After a data deletion request</td><td>Game data is deleted within a reasonable time; purchase records are kept anonymised for the statutory period</td></tr>
<tr><td>Server request logs</td><td>30 days</td></tr>
</table></div>

<h2>7. Your rights</h2>
<p>Under KVKK Art. 11 and the GDPR you have the right to know whether your data is processed, to request information and a copy,
to rectification, erasure, restriction and objection, and to data portability.</p>
<ul>
<li><strong>Deleting your data:</strong> email {EMAIL} with the subject "Dashink data deletion". Your progress, coins, items and
session data are deleted from our server, and your anonymous customer record at RevenueCat is removed. Purchase transaction records
that we must keep by law are retained separately and can no longer be linked to any device or person. Where possible, include your
app version and platform (iOS / Android) so we can find your account.</li>
<li><strong>Other requests</strong> (information, copy, objection): {EMAIL}. We respond within 30 days at the latest.</li>
<li>You may also lodge a complaint with the Turkish Personal Data Protection Authority or the data protection authority in your
country.</li>
</ul>

<h2>8. Children</h2>
<p>Dashink is an arcade game suitable for players of all ages and does not ask for a name, email or contact details. We do not
knowingly collect personal information from children under 13; the game only uses the anonymous identifier it needs to work. We
recommend parents use their device's purchase restrictions (e.g. "Ask to Buy") for in-app purchases. If you believe we process a
child's data, let us know at {EMAIL} and we will delete it. See also our
<a href="../csae/">Child Safety Standards (CSAE)</a>.</p>

<h2>9. Security</h2>
<p>Data is encrypted in transit with TLS; session keys are stored in the device's secure storage and server access is restricted.
No system is 100% secure, but we take reasonable technical and organisational measures to protect your data.</p>

<h2>10. Notifications</h2>
<p>Daily reminder notifications are optional; you can turn them off anytime via device permission and the App's
<em>Settings</em>. Notifications are scheduled locally on the device; no push notification service is used.</p>

<h2>11. Changes</h2>
<p>We may update this policy. We will inform you in the App about significant changes. The current version is always on this
page.</p>

<h2>12. Contact</h2>
<p>For questions and requests: {EMAIL}</p>
"""

# ───────────────────────────── KOŞULLAR ─────────────────────────────

TERMS_TR = f"""
<div class="note"><strong>Kısaca:</strong> Dashink ücretsiz oynanır ve reklam içermez. İsteğe bağlı olarak Dashink Premium
(tek seferlik satın alma) alabilirsin. Coin'lerin gerçek para değeri yoktur, nakde çevrilemez ve başkasına
devredilemez.</div>

<h2>1. Kabul</h2>
<p>Dashink uygulamasını ("Uygulama") indirerek veya kullanarak bu Kullanım Koşulları'nı ve
<a href="../privacy-policy/">Gizlilik Politikası</a>'nı kabul etmiş olursun. Kabul etmiyorsan Uygulamayı kullanma. Uygulama
Fly Work ("biz") tarafından sunulur.</p>

<h2>2. Oyun</h2>
<p>Dashink; yuvarlanan topun yolunu mürekkep çizgileriyle yönlendirdiğin bir arcade oyunudur. Günlük meydan okuma, görevler,
sıralama ve mağaza (top, mürekkep, tema) sunar. Özellikleri, ödülleri ve fiyatları zaman içinde değiştirebilir, ekleyebilir veya
kaldırabiliriz.</p>

<h2>3. Oyuncu hesabı</h2>
<ul>
<li>Uygulama, cihazına bağlı anonim bir oyuncu hesabıyla çalışır; kayıt veya giriş gerekmez.</li>
<li>İlerlemen ve coin bakiyen sunucumuzda bu hesaba bağlı saklanır. Cihazı sıfırlarsan, değiştirirsen veya (özellikle Android'de)
uygulamayı silersen hesabına erişimini kaybedebilirsin. Böyle bir durumda {EMAIL} adresinden bize ulaşabilirsin.</li>
<li>Oyun içi ilerlemeyi, skorları veya coin'leri hile, otomasyon veya güvenlik açığı kullanarak elde etmek yasaktır.</li>
</ul>

<h2>4. Sanal para birimi (coin) ve oyun içi öğeler</h2>
<ul>
<li>Coin'leri oyun oynayarak, görevleri tamamlayarak ve günlük sıra ödülleriyle kazanabilirsin. Dashink Premium bir kez bonus
coin de verir.</li>
<li>Coin'lerle mağazadan top, mürekkep rengi ve tema gibi öğeler alınabilir. Coin'ler ve oyun içi öğeler sana Uygulama içinde
kullanman için verilen, <strong>sınırlı, devredilemez ve geri alınabilir bir lisanstır</strong>; mülkiyet hakkı doğurmaz.</li>
<li>Coin'lerin ve öğelerin <strong>gerçek para değeri yoktur</strong>; nakde çevrilemez, satılamaz, başka hesaba aktarılamaz.</li>
</ul>

<h2>5. Dashink Premium ve ödemeler</h2>
<ul>
<li>Dashink Premium tek seferlik (non-consumable) bir satın almadır; abonelik değildir ve otomatik yenilenmez. Premium bazı
öğeleri açar ve bir kez bonus coin verir.</li>
<li>Fiyatlar satın alma ekranında, mağazanın gösterdiği para birimiyle gösterilir. Ödeme, satın alımı onaylamanla App Store veya
Google Play hesabından alınır.</li>
<li>Satın alımın görünmüyorsa <em>Ayarlar → Satın Alımları Geri Yükle</em>'yi kullan veya bize yaz.</li>
<li>Bir satın alma mağaza tarafından iade edilirse premium erişimi ve ilgili bonus geri alınabilir.</li>
<li>İadeler ilgili mağazanın politikalarına tabidir. Yürürlükteki tüketici mevzuatından doğan hakların saklıdır; dijital içeriğin
anında ifasına onay verdiğin durumlarda cayma hakkı mevzuatın izin verdiği ölçüde sınırlanabilir.</li>
<li>18 yaşından küçüksen satın alma yapmadan önce ebeveyninin veya vasinin iznini almalısın.</li>
</ul>

<h2>6. Sıralama ve paylaşım</h2>
<ul>
<li>Sıralamada otomatik üretilen görünen adın ve skorun diğer oyunculara görünür.</li>
<li>Skor klipini paylaşmak isteğe bağlıdır; paylaşım cihazının kendi paylaşım sayfası üzerinden yapılır.</li>
</ul>

<h2>7. Kabul edilebilir kullanım</h2>
<p>Uygulamayı kullanırken şunları yapmamayı kabul edersin: tersine mühendislik, kazıma veya otomatik araçlarla kötüye kullanım;
hile yazılımı veya değiştirilmiş istemci kullanmak; sunucularımıza aşırı yük bindirmek; güvenlik önlemlerini veya ödeme sistemini
atlatmaya çalışmak. İhlal halinde ilgili ilerleme, coin, premium veya hesap iptal edilebilir.</p>

<h2>8. Fikri mülkiyet</h2>
<p>Uygulama, tasarımlar, sesler, metinler ve yazılım bize veya lisans verenlerimize aittir. Sana Uygulamayı kişisel ve ticari
olmayan amaçla kullanman için sınırlı, devredilemez bir kullanım hakkı veriyoruz.</p>

<h2>9. Üçüncü taraf hizmetleri</h2>
<p>Apple, Google ve RevenueCat gibi hizmetlerin kullanımı, o hizmetlerin kendi koşullarına tabidir.</p>

<h2>10. Sorumluluğun sınırlandırılması</h2>
<p>Uygulama "olduğu gibi" sunulur. Kesintisiz veya hatasız çalışacağını garanti etmeyiz. Yürürlükteki hukukun izin verdiği ölçüde;
Uygulamanın kullanımından doğan dolaylı zararlardan sorumlu değiliz. Kast veya ağır ihmalden doğan sorumluluk ile tüketici olarak
sahip olduğun yasal haklar saklıdır.</p>

<h2>11. Fesih</h2>
<p>Uygulamayı istediğin zaman kullanmayı bırakabilir ve veri silme talebiyle ({EMAIL}) verilerini sildirebilirsin; bu durumda
kalan coin'lerin ve ilerlemen geri getirilemez. Bu koşulları ihlal edersen hesabını askıya alabilir veya kapatabiliriz.</p>

<h2>12. Uygulanacak hukuk</h2>
<p>Bu koşullar Türkiye Cumhuriyeti hukukuna tabidir. Tüketici olarak ikamet ettiğin ülkenin emredici hükümlerinden doğan hakların
saklıdır.</p>

<h2>13. Değişiklikler</h2>
<p>Bu koşulları güncelleyebiliriz. Önemli değişikliklerde Uygulama içinde bilgilendiririz.</p>

<h2>14. İletişim</h2>
<p>{EMAIL}</p>
"""

TERMS_EN = f"""
<div class="note"><strong>In short:</strong> Dashink is free to play and has no ads. You can optionally buy Dashink Premium
(a one-time purchase). Coins have no real-world monetary value, cannot be cashed out and cannot be transferred to others.</div>

<h2>1. Acceptance</h2>
<p>By downloading or using the Dashink app (the "App") you accept these Terms of Use and our
<a href="../privacy-policy/">Privacy Policy</a>. If you do not agree, do not use the App. The App is provided by Fly Work
("we").</p>

<h2>2. The game</h2>
<p>Dashink is an arcade game where you guide a rolling ball by drawing ink lines. It offers a daily challenge, tasks,
leaderboards and a shop (balls, ink, themes). We may change, add or remove features, rewards and prices over time.</p>

<h2>3. Player account</h2>
<ul>
<li>The App works with an anonymous player account tied to your device; no sign-up or login is required.</li>
<li>Your progress and coin balance are stored on our server under this account. If you reset or change your device, or uninstall
the App (especially on Android), you may lose access to your account. If that happens, contact us at {EMAIL}.</li>
<li>Obtaining progress, scores or coins through cheats, automation or security vulnerabilities is prohibited.</li>
</ul>

<h2>4. Virtual currency (coins) and in-game items</h2>
<ul>
<li>You can earn coins by playing, completing tasks and daily rank rewards. Dashink Premium also grants a one-time bonus coin
amount.</li>
<li>Coins can be spent in the shop on balls, ink colours and themes. Coins and in-game items are a <strong>limited,
non-transferable, revocable licence</strong> to use them within the App; they do not grant ownership.</li>
<li>Coins and items have <strong>no real-world monetary value</strong>; they cannot be exchanged for cash, sold or transferred to
another account.</li>
</ul>

<h2>5. Dashink Premium and payments</h2>
<ul>
<li>Dashink Premium is a one-time (non-consumable) purchase; it is not a subscription and does not renew automatically. Premium
unlocks certain items and grants a one-time coin bonus.</li>
<li>Prices are shown on the purchase screen in the currency provided by the store. Payment is charged to your App Store or Google
Play account when you confirm the purchase.</li>
<li>If a purchase does not appear, use <em>Settings → Restore Purchases</em> or contact us.</li>
<li>If a purchase is refunded by the store, premium access and the related bonus may be revoked.</li>
<li>Refunds are subject to the respective store's policies. Your statutory consumer rights remain unaffected; where you consent to
immediate performance of digital content, the right of withdrawal may be limited as permitted by law.</li>
<li>If you are under 18, get permission from a parent or guardian before making a purchase.</li>
</ul>

<h2>6. Leaderboards and sharing</h2>
<ul>
<li>Your auto-generated display name and score are visible to other players on leaderboards.</li>
<li>Sharing a score clip is optional and uses your device's own share sheet.</li>
</ul>

<h2>7. Acceptable use</h2>
<p>You agree not to: reverse engineer, scrape or abuse the App with automated tools; use cheat software or modified clients; place
excessive load on our servers; or try to circumvent security measures or the payment system. Violations may result in the affected
progress, coins, premium or account being revoked.</p>

<h2>8. Intellectual property</h2>
<p>The App, designs, sounds, texts and software belong to us or our licensors. We grant you a limited, non-transferable right to
use the App for personal, non-commercial purposes.</p>

<h2>9. Third-party services</h2>
<p>Use of services such as Apple, Google and RevenueCat is subject to their own terms.</p>

<h2>10. Limitation of liability</h2>
<p>The App is provided "as is". We do not guarantee that it will operate without interruption or errors. To the extent permitted
by applicable law, we are not liable for indirect damages arising from the use of the App. Liability for intent or gross
negligence and your statutory rights as a consumer remain unaffected.</p>

<h2>11. Termination</h2>
<p>You can stop using the App at any time and request deletion of your data ({EMAIL}); your remaining coins and progress cannot
be restored afterwards. If you violate these terms, we may suspend or close your account.</p>

<h2>12. Governing law</h2>
<p>These terms are governed by the laws of the Republic of Türkiye. Mandatory consumer protection rights of your country of
residence remain unaffected.</p>

<h2>13. Changes</h2>
<p>We may update these terms. We will inform you in the App about significant changes.</p>

<h2>14. Contact</h2>
<p>{EMAIL}</p>
"""

# ───────────────────────────── ÇEREZLER ─────────────────────────────

COOKIES_TR = f"""
<div class="note">Kısaca: Dashink <strong>reklam veya takip çerezi kullanmaz</strong>. Uygulama, yalnızca çalışması için
gereken bilgileri cihazında saklar. Bu sayfalar da çerez veya yerel depolama kullanmaz.</div>

<h2>1. Çerez nedir?</h2>
<p>Çerezler, web sitelerinin tarayıcına kaydettiği küçük dosyalardır. Mobil uygulamalar tarayıcı çerezi yerine cihazdaki benzer
depolama alanlarını (ör. güvenli anahtar deposu, uygulama tercihleri) kullanır. Bu politika her ikisini de kapsar.</p>

<h2>2. Uygulamanın cihazında sakladığı bilgiler</h2>
<p>Bunların tamamı <strong>zorunlu</strong> niteliktedir; Uygulamanın çalışması için gerekir ve reklam ya da takip amacıyla
kullanılmaz:</p>
<div class="table"><table>
<tr><th>Bilgi</th><th>Amaç</th><th>Nerede</th></tr>
<tr><td>Oturum anahtarları (erişim / yenileme)</td><td>Oyuncu hesabına bağlı kalmanı sağlamak</td><td>Cihazın güvenli deposu (Keychain / Keystore)</td></tr>
<tr><td>Rastgele cihaz kimliği</td><td>Anonim oyuncu hesabını cihazına bağlamak</td><td>Cihazın güvenli deposu</td></tr>
<tr><td>Ses, müzik, titreşim ve bildirim tercihleri</td><td>Ayarlarını hatırlamak</td><td>Uygulama tercihleri</td></tr>
<tr><td>Dil tercihi</td><td>Arayüz dilini hatırlamak</td><td>Uygulama tercihleri</td></tr>
</table></div>
<p>Uygulamayı kaldırdığında bu bilgiler cihazından kaldırılır (iOS'ta güvenli depodaki cihaz kimliği, aynı cihaza yeniden
kurulumda ilerlemeni geri getirmek için korunabilir).</p>

<h2>3. Üçüncü taraf bileşenler</h2>
<ul>
<li><strong>RevenueCat:</strong> Satın almaları doğrulamak için anonim bir kullanıcı kimliği kullanır.</li>
</ul>
<p>Uygulamada reklam, analitik veya uygulamalar arası takip <strong>yoktur</strong>.</p>

<h2>4. Bu web sayfaları</h2>
<p>Dashink yasal sayfaları çerez, yerel depolama veya analitik araç kullanmaz. Dil seçimi yalnızca sayfa adresi üzerinden
yapılır.</p>

<h2>5. Tercihlerini yönetme</h2>
<ul>
<li>Ses, müzik, titreşim ve bildirimleri uygulamadaki <em>Ayarlar</em> ekranından değiştirebilirsin.</li>
<li>Uygulamanın cihazında sakladığı bilgileri uygulamayı kaldırarak silebilirsin.</li>
<li>Ayrıntılar için <a href="../privacy-policy/">Gizlilik Politikası</a>'na bak.</li>
</ul>

<h2>6. İletişim</h2>
<p>{EMAIL}</p>
"""

COOKIES_EN = f"""
<div class="note">In short: Dashink <strong>does not use advertising or tracking cookies</strong>. The App only stores on your
device what it needs to work. These pages do not use cookies or local storage either.</div>

<h2>1. What are cookies?</h2>
<p>Cookies are small files that websites store in your browser. Mobile apps use similar storage on the device (e.g. secure key
storage, app preferences) instead of browser cookies. This policy covers both.</p>

<h2>2. Information the App stores on your device</h2>
<p>All of this is <strong>strictly necessary</strong> for the App to work and is not used for advertising or tracking:</p>
<div class="table"><table>
<tr><th>Information</th><th>Purpose</th><th>Where</th></tr>
<tr><td>Session keys (access / refresh)</td><td>Keeping you connected to your player account</td><td>Device secure storage (Keychain / Keystore)</td></tr>
<tr><td>Random device identifier</td><td>Linking the anonymous player account to your device</td><td>Device secure storage</td></tr>
<tr><td>Sound, music, haptics and notification preferences</td><td>Remembering your settings</td><td>App preferences</td></tr>
<tr><td>Language preference</td><td>Remembering the UI language</td><td>App preferences</td></tr>
</table></div>
<p>Uninstalling the App removes this information from your device (on iOS, the device identifier in secure storage may be kept so
that your progress returns if you reinstall on the same device).</p>

<h2>3. Third-party components</h2>
<ul>
<li><strong>RevenueCat:</strong> uses an anonymous user ID to verify purchases.</li>
</ul>
<p>There is <strong>no</strong> advertising, analytics or cross-app tracking in the App.</p>

<h2>4. These web pages</h2>
<p>The Dashink legal pages do not use cookies, local storage or analytics. The language is selected only via the page
address.</p>

<h2>5. Managing your preferences</h2>
<ul>
<li>You can change sound, music, haptics and notifications in the App's <em>Settings</em> screen.</li>
<li>You can delete the information stored on your device by uninstalling the App.</li>
<li>See our <a href="../privacy-policy/">Privacy Policy</a> for details.</li>
</ul>

<h2>6. Contact</h2>
<p>{EMAIL}</p>
"""

# ───────────────────────────── CSAE ─────────────────────────────

CSAE_TR = f"""
<div class="note">Dashink, <strong>çocukların cinsel istismarı ve sömürüsüne (CSAE)</strong> ve çocuk cinsel istismarı
materyaline (CSAM) karşı <strong>sıfır tolerans</strong> politikası uygular.</div>

<h2>1. Kapsam</h2>
<p>Bu standartlar Dashink uygulaması ve ilgili tüm hizmetler için geçerlidir. Dashink tek oyunculu bir arcade oyunudur;
kullanıcılar arası mesajlaşma, sohbet, kullanıcı tarafından yüklenen içerik veya herkese açık sosyal akış
<strong>yoktur</strong>. Sıralamada yalnızca otomatik üretilen görünen ad ve skor görünür.</p>

<h2>2. Yasaklanan içerik ve davranışlar</h2>
<ul>
<li>Çocukların cinsel istismarını gösteren, teşvik eden veya cinselleştiren her türlü görsel, metin veya diğer içerik (CSAM).</li>
<li>Çocuklarla cinsel amaçlı iletişim kurmaya, onları kandırmaya veya istismara yönelik her türlü girişim (grooming).</li>
<li>Çocukların cinsel sömürüsünü, insan ticaretini veya bunlara aracılığı içeren her türlü faaliyet.</li>
</ul>

<h2>3. Önleme</h2>
<ul>
<li>Uygulamada kullanıcılar arası iletişim kanalı ve kullanıcı içeriği yüklenecek bir alan bulunmaz.</li>
<li>Uygulama ad, e-posta, fotoğraf veya konum gibi kişisel bilgiler istemez.</li>
</ul>

<h2>4. Bildirim</h2>
<p>Uygulamada veya hizmetlerimizde çocuk güvenliğini tehdit eden bir içerik ya da davranış görürsen hemen bize bildir:</p>
<ul>
<li><strong>E-posta:</strong> {EMAIL} (konu: "Çocuk güvenliği")</li>
</ul>
<p>Bir çocuk acil tehlikedeyse önce <strong>112</strong>'yi (veya bulunduğun ülkedeki acil durum hattını) ara.</p>

<h2>5. Müdahale</h2>
<ul>
<li>Bildirimler öncelikli olarak incelenir.</li>
<li>Çocuk cinsel istismarı materyali tespit edildiğinde yürürlükteki yasalar uyarınca yetkili makamlara bildirilir ve soruşturmalarda
yetkili makamlarla iş birliği yapılır.</li>
</ul>

<h2>6. Yasalara uyum</h2>
<p>Dashink, çocuk güvenliğine ilişkin yürürlükteki yasalara ve Google Play ile App Store politikalarına uyar.</p>

<h2>7. Çocuk güvenliği irtibat kişisi</h2>
<p>Çocuk güvenliği uygulamalarımız ve bu standartlar hakkında soruların için irtibat: {EMAIL}</p>
"""

CSAE_EN = f"""
<div class="note">Dashink has a <strong>zero-tolerance</strong> policy against <strong>child sexual abuse and exploitation
(CSAE)</strong> and child sexual abuse material (CSAM).</div>

<h2>1. Scope</h2>
<p>These standards apply to the Dashink app and all related services. Dashink is a single-player arcade game; there is
<strong>no</strong> messaging, chat, user-uploaded content or public social feed. Leaderboards only show an auto-generated
display name and score.</p>

<h2>2. Prohibited content and behaviour</h2>
<ul>
<li>Any imagery, text or other content depicting, promoting or sexualising the sexual abuse of children (CSAM).</li>
<li>Any attempt to contact, deceive or exploit children for sexual purposes (grooming).</li>
<li>Any activity involving or facilitating the sexual exploitation or trafficking of children.</li>
</ul>

<h2>3. Prevention</h2>
<ul>
<li>The App has no communication channel between users and no area for uploading user content.</li>
<li>The App does not ask for personal information such as name, email, photos or location.</li>
</ul>

<h2>4. Reporting</h2>
<p>If you see content or behaviour in our App or services that threatens child safety, report it to us immediately:</p>
<ul>
<li><strong>Email:</strong> {EMAIL} (subject: "Child safety")</li>
</ul>
<p>If a child is in immediate danger, first call your local emergency number (<strong>112</strong> in Türkiye and the EU).</p>

<h2>5. Response</h2>
<ul>
<li>Reports are reviewed with priority.</li>
<li>Where child sexual abuse material is identified, it is reported to the competent authorities as required by law, and we
cooperate with authorities in investigations.</li>
</ul>

<h2>6. Legal compliance</h2>
<p>Dashink complies with applicable child safety laws and with Google Play and App Store policies.</p>

<h2>7. Child safety point of contact</h2>
<p>For questions about our child safety practices and these standards: {EMAIL}</p>
"""

# ───────────────────────────── HAKKINDA ─────────────────────────────

ABOUT_TR = f"""
<div class="note"><strong>Dashink</strong>, yuvarlanan topun önüne mürekkep çizerek yolu çizdiğin hızlı bir arcade
oyunudur. Bir Fly Work ürünüdür. Reklam yok, kayıt yok — sadece sen, top ve mürekkep.</div>

<h2>1. Nasıl oynanır?</h2>
<ul>
<li>Parmağınla mürekkep çiz; top çizdiğin yola göre yuvarlanır.</li>
<li>Mümkün olduğunca uzağa git, engellerden kaç ve yüksek skor yap.</li>
<li>Günlük meydan okumayı dene, görevleri tamamla ve sıralamada yerini gör.</li>
<li>Coin'lerle mağazadan top, mürekkep rengi ve tema aç.</li>
</ul>

<h2>2. Satın alımlar</h2>
<p>Oyun ücretsizdir. İsteğe bağlı Dashink Premium (tek seferlik) App Store ve Google Play üzerinden satın alınır. Ayrıntılar:
<a href="../terms/?lang=tr">Kullanım Koşulları</a> ve <a href="../privacy-policy/?lang=tr">Gizlilik Politikası</a>.</p>

<h2>3. Destek</h2>
<ul>
<li>E-posta: {EMAIL}</li>
<li>Web: <a href="https://fly-work.com">fly-work.com</a> · <a href="https://fly-work.com/contact-us/">İletişim formu</a></li>
<li>Premium görünmüyorsa: <em>Ayarlar → Satın Alımları Geri Yükle</em>.</li>
</ul>
"""

ABOUT_EN = f"""
<div class="note"><strong>Dashink</strong> is a fast arcade game where you draw ink lines to guide a rolling ball. A Fly Work
product. No ads, no sign-up — just you, the ball and the ink.</div>

<h2>1. How to play</h2>
<ul>
<li>Draw ink with your finger; the ball rolls along the path you create.</li>
<li>Go as far as you can, avoid obstacles and chase a high score.</li>
<li>Try the daily challenge, complete tasks and check the leaderboards.</li>
<li>Spend coins in the shop on balls, ink colours and themes.</li>
</ul>

<h2>2. Purchases</h2>
<p>The game is free. Optional Dashink Premium (one-time) is purchased through the App Store and Google Play. Details:
<a href="../terms/?lang=en">Terms of Use</a> and <a href="../privacy-policy/?lang=en">Privacy Policy</a>.</p>

<h2>3. Support</h2>
<ul>
<li>Email: {EMAIL}</li>
<li>Web: <a href="https://fly-work.com">fly-work.com</a> · <a href="https://fly-work.com/contact-us/">Contact form</a></li>
<li>Premium not showing? Use <em>Settings → Restore Purchases</em>.</li>
</ul>
"""

PAGES = {
    "about": {
        "title": {"tr": "Dashink Hakkında", "en": "About Dashink"},
        "desc": "About Dashink — ink arcade game by Fly Work / Dashink hakkında",
        "body": {"tr": ABOUT_TR, "en": ABOUT_EN},
    },
    "privacy-policy": {
        "title": {"tr": "Dashink – Gizlilik Politikası", "en": "Dashink – Privacy Policy"},
        "desc": "Dashink privacy policy / gizlilik politikası",
        "body": {"tr": PRIVACY_TR, "en": PRIVACY_EN},
    },
    "terms": {
        "title": {"tr": "Dashink – Kullanım Koşulları", "en": "Dashink – Terms of Use"},
        "desc": "Dashink terms of use / kullanım koşulları",
        "body": {"tr": TERMS_TR, "en": TERMS_EN},
    },
    "cookies": {
        "title": {"tr": "Dashink – Çerez Politikası", "en": "Dashink – Cookie Policy"},
        "desc": "Dashink cookie policy / çerez politikası",
        "body": {"tr": COOKIES_TR, "en": COOKIES_EN},
    },
    "csae": {
        "title": {
            "tr": "Dashink – Çocuk Güvenliği Standartları (CSAE)",
            "en": "Dashink – Child Safety Standards (CSAE)",
        },
        "desc": "Dashink child safety standards against CSAE / çocuk güvenliği standartları",
        "body": {"tr": CSAE_TR, "en": CSAE_EN},
    },
}
