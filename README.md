# FrameOk

## Вступление

**FrameOk** – это наш набор инструментов компании **MobileUp**, который используем при разработке мобильных приложений для платформы **iOS**.

В него также входит **Mutal** –  полезная утилита для отладки приложения, которая умеет симулировать ошибки сети, автозаполнять поля форм, просматривать логи, менять окружение бэкэнда и запускать кастомные отладочные сценарии.

## Применение

**FrameOk** хорошо сочетается с современными и классическими архитектурами мобильных приложений **iOS** – например, с **Clean Architecture** или **MVCS**. 

## Установка

### Зависимости

Фрейм использует несколько внешних зависимостей с помощью CocoaPods: 

    pod 'Alamofire'
    pod 'AlamofireNetworkActivityLogger'
    pod 'Kingfisher'
    pod 'PhoneNumberKit'
    pod 'XCGLogger'
    pod 'GCDWebServer'
    pod "SkeletonView"
    pod 'SwiftEntryKit'
    pod 'InputMask'

## Mutal

### Включение

Для включения отладочной утилиты и логирования добавьте код в **AppDelegate** вашего проекта:

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    ...
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ...
        MUDeveloperToolsManager.setup()
        ...
    }
```

Настройте логику в зависимости от окружения:
```swift
MULogManager.isEnabled = isDevelop
MUDeveloperToolsManager.isEnabled = isDevelop
```

### Запуск

Чтобы открыть отладочную панель утилиты встряхните свой тестовый девайс или вызовите команду **Shake** на симуляторе (**cmd + ctrl + z**).

### Смена окружений

Для динамической смены окружения налету реализуйте протокол **DeveloperToolsDelegate**:

```swift
extension Environments: MUDeveloperToolsDelegate {

    // MARK: - Environment

    private enum Environment {

        static let develop = "develop"
        static let production = "production"
    }

    // MARK: - Public methods

    func developerToolsEnvironmentArray() -> [MUEnvironment] {

        return [

            MUEnvironment(index: Environment.develop, title: "Develop"),
            MUEnvironment(index: Environment.production, title: "Production")
        ]
    }

    func developerToolsDidEnvironmentChanged(with environment: MUEnvironment) {

        switch environment.index {

        case Environment.develop    : Environments.isProduction = false
        case Environment.production : Environments.isProduction = true
        default                     : break
        }
    }
}
```

и передайте ссылку на делегат:

```swift
MUDeveloperToolsManager.delegate = self
```

### Автозаполнение форм

Для автозаполнения полей в вашем контроллере добавьте такой метод:

```swift
func addDebugData(with data: String, to field: UITextField?) {
        
    if MUDeveloperToolsManager.shouldAutoCompleteForms {
       
        field?.value = value
    }
}

```

и вызывайте его в **viewDidLoad**:


```swift
override func viewDidLoad() {
    ...
    addDebugData("test@test.com", to: emailTextField)
    ...
}
```

### Генерация случайных данных

Добавление к полям форм отладочных значений или генерации  случайных данных (электронной почты, телефона, логина, пароля и т.д). Это удобно, например, на экране регистрации нового пользователя:

```swift
addDebugData(MUDevelopData.defaultEmail, to: emailTextField)
addDebugData(MUDevelopData.randomLogin, to: loginTextField)
addDebugData(MUDevelopData.randomPassword, to: passwordTextField)
addDebugData(MUDevelopData.randomPhone, to: phoneTextField)
```

Добавление к полю формы ранее случайно сгенерированных данных (например, на экране авторизации пользователя):

```swift
addDebugData(MUDevelopData.previousLogin, to: loginTextField)
addDebugData(MUDevelopData.previousPassword, to: passwordTextField)
```

### Кастомные отладочные сценарии

Часто бывает полезно реализовывать отладочные сценарии, которые позволяют сокращать время воспроизведения прохождения тестовых кейсов. 

#### Пример:

У нас приложение, в котором пользователю необходимо правильно ответить на 200 вопросов. Нам будет удобно спрятать чит-кнопку. 

По её нажатию, разработчик должен иметь быстрый доступ к экрану успеха и дальнейшей логике приложения (например, начисления баллов, разблокирование ачивок и тп). Такую кнопку удобно спрятать в отладочную панель. 

Для добавления кастомных действий к своему экрану в его контроллере нужно реализовать протокол **DeveloperToolsCustomActionDelegate**:

```swift
extension ViewController: DeveloperToolsCustomActionDelegate {

    func developerToolCustomActionDidTapped(_ developerTools: DeveloperToolsController) {
        ...
    }
}
```

и передать ссылку, например, в **viewDidLoad**:
```swift
MUDeveloperToolsManager.customActionDelegate = self
```

Запустите приложение, перейдите на нужный экран, откройте отладочную панель и тапните на **Custom Action**. 

### Логирование

Отправка сообщений в лог приложения по категориям:

```swift
Log.details("...")
Log.event("...")
Log.error("...")
Log.critical("...")
```

### Сетевые ошибки

Симуляция сетевых ошибок из коробки будет работать, если вы использовали для своего сетевого модуля  **MUDataTransferManager** или **MUNetworkManager**.

Для кастомных сетевых модулей вы можете использовать эти логические свойства и реализовать необходимую логику самостоятельно:

```swift
MUDeveloperToolsManager.alwaysReturnConnectionError
MUDeveloperToolsManager.alwaysReturnServerError
MUDeveloperToolsManager.shouldSimulateBadConnection
```

Например:
```swift
if MUDeveloperToolsManager.alwaysReturnConnectionError {

    failure(MUNetworkError.connectionError)
}
```

## Сетевой модуль

Вы можете создать свой сетевой модуль на основе базового класса **MUDataTransferManager**.  Он обеспечит работу с сетью, логирование сетевой активности, сериализацию данных, базовую логику авторизации данных и обработки ошибок:
 
```swift
class AppServerClient: MUDataTransferManager {
    ...
}
```

### Установка headers

Если у вас авторизация **Bearer**, то вы можете передать **request token** в свойство **token**:


```swift
token = response.requestToken
```

Для настройки **headers** перезапишите метод **getHeaders**:
```swift

override func getHeaders() -> [String : String] {
    
    var headers = super.getHeaders()
    headers.setValue(..., forKey: "Authorization")
    return headers
}

```

### Обработка ответов

Если вам необходимо реализовать общую логику для обработки полученных ответов от сервера (обработка ошибок, обновление токена и т.п.), то будет удобно перезаписать метод **handlerResponse**:
 
```swift
    override func handlerResponse(

        result    : Any,
        request   : MUNetworkRequest?,
        recipient : NSObject? = nil,
        success   : ((Any) -> Void)? = nil,
        failure   : ((Error?) -> Void)? = nil
    ) {
        
        guard ... else {
            
            failure?(AppError.parsingError)
            
            return
        }

        success?(result)
    }
```

### Обработка неудачных запросов

В этом методе необходимо реализовать логику конвертации ошибок сети и сериализации данных. Например, привести ошибки к общему **enum** приложения **AppError**.

```swift

    override func handleFailure(

        result     : Any?,
        error      : MUNetworkError?,
        request    : MUNetworkRequest?,
        recipient  : NSObject?,
        completion : ((Error?) -> Void)? = nil
    ) {
    
        return returnError(

            with      : AppError.convertNetworkError(error: error ?? MUNetworkError.unknownError),
            recipient : recipient,
            failure   : completion
        )
    }
```

## Обработка ошибок

Создайте общий enum и перечислите в нём все возможные ошибки, которые могут возникнуть в приложении: 

```swift
enum AppError: Error, Equatable {
    
    case unknownError
    case parsingError
    case connectionError
    case temporaryNotAvalibleError
    case serverError
    case lostParameter(String)
    ...
}
```

Конвертируйте ошибки других типов в общий enum:

```swift
extension AppError {

    static func convertNetworkError(error: MUNetworkError) -> AppError {

        switch error {

            case .connectionError         : return AppError.connectionError
            case .serverError             : return AppError.serverError
            case .parsingError            : return AppError.parsingError
            case .unknownError            : return AppError.unknownError
            ...
        }
    }
}
```

Вы может отправлять ошибки из любого места в коде приложения и получать их через **NotificationCenter** . Для этого добавьте такой код для своего **AppError**:
```swift
extension AppError {

    // MARK: - Public properties

    static var recipient: NSObject? { didSet { MUErrorManager.recipient = recipient } }

    // MARK: - Public methods

    static func post(with error: AppError, for recipient: NSObject? = nil) {

        MUErrorManager.post(with: error, for: recipient)
    }

    func post(for recipient: NSObject? = nil) {

        MUErrorManager.post(with: self, for: recipient)
    }
}
```

Отправление ошибки:
```swift
guard let login = login else {

   return AppError.lostParameter("login").post()
}
```

Получение ошибки с помощью NotificationCenter и добавление её в лог:
```swift
NotificationCenter.addObserver(for: self, forName: .appErrorDidCome) { [weak self] notification in
    
        guard let notification = notification.userInfo?["notification"] as? MUErrorNotification else {
            
            return AppError.unknownError.post()
        }
        
        guard notification.recipient == self else {
            
            return
        }
        
        Log.error("error: \(notification)")
        
        guard let error = notification.error as? AppError else {
            
            return
        }
        
        appErrorDidBecome(error: error)
}
```


## Модели данных

Все модели данных должны соответствовать протоколам **MUModel**, **MUCodable**:
```swift
final class Entity: MUModel, MUCodable {
    
    var primaryKey: String { return id }
    ...
}
```


## Контроллеры

В состав фрейма входит три базовых контроллера:
- MUViewController
- MUListController
- MUFormController


## MUViewController

Все простые экраны проекта нужно наследовать от вашего базового **ViewController**, который наследуется от **MUViewController**.

```swift
class ViewController: MUViewController
```

#### Базовый функционал:

- роутинг
- получение ошибок API по умолчанию
- контейнер над клавиатурой
- показ сообщений и диалогов
- показ индикаторов активности

## Роутинг

### Инициализация из Storyboard 

Название контролера должно совпадать с его **Storyboard ID** на вкладке **Identity** в **Storyboard**:

```swift
class CatalogueController: ViewController {

    class override var storyboardName: String { return "Catalogue" }
}
```

### Инициализация из Xib 

Название xib файла должно совпадать с названием класса:
```swift
MUViewController.defaultInstantiateMethod = .fromNib
```

### Получение инстанса
```swift
CatalogueController.instantiate()
```

### Навигация

Переход к контроллеру из другого контроллера:

```swift
push(with: CatalogueController.self) { instance in

    instance.productId = productId
}
```

Презент контроллера в другом контроллере:
```swift
present(with: CatalogueController.self) { instance in

    instance.productId = productId
}
```
Презент контроллера в другом контроллере со своей навигацией:
```swift
present(with: CatalogueController.self, withNavigation: true)
```

Вставка контроллера во view другого контроллера:
```swift
insert(controller: CatalogueController.instantiate(), into: self.view)
remove(child: childrenController)
```

### Обработка ошибок

Если ошибки были отправлены с помощью NotificationCenter, то их может поймать MU контроллер из коробки.

Получение ошибки в классе базового контроллера, наследуемого от MUViewController:

```swift
override func appErrorDidBecome(error: Error) {

    guard let error = error as? AppError else {

        return
    }

    appErrorDidBecome(error: error)
}

func appErrorDidBecome(error: AppError) {

}
```

Далее уже в контроллере экрана можно обрабатывать ошибку:
```swift
override func appErrorDidBecome(error: AppError) {
    ...
}
```

Отключить получение ошибок для контроллера:
```swift
override var isErrorRecipient: Bool { false }
```

#### Показ нативного алерта

```swift
showPopup(

    title       : "Error",
    message     : AppError.unknownError.localizedDescription,
    buttonTitle : "Ok",
    action      : { ... }
)
```

#### Показ нативного алерта с кнопками

```swift

showDialogAlert(

    title             : "Error",
    message           :  AppError.unknownError.localizedDescription,
    leftButtonTitle   : "Ok",
    rightButtonTitle  : "Cancel",
    leftButtonStyle   : .default,
    rightButtonStyle  : .cancel,
    leftButtonAction  : { ... },
    rightButtonAction : { ... }
)
```

#### Показ тоста

```swift
showToast(

    title    : "Connection error",
    message  : AppError.connectionError.localizedDescription,
    duration : 2
)
```

#### Показ кастомной вью

```swift
show(

    customView     : CustomAlert.instantiate(),
    position       : .center,
    animationType  : .fade
)
```

#### Показ контроллера

```swift
show(controller: CatalogueController.instantiate())
```

#### Показ нижнего модального окна

```swift
showBottomPopup(

    controller           : TransactionController.instantiate(),
    backgroundColorStyle : backgroundColorStyle,
    arrowIcon            : R.image.common.icomCloseBottomPopup(),
    arrowIconOffset      : 8
)
```

#### Закрыть все попапы

```swift
popupControl.closeAll()
```

#### Проверка видимости попапа

```swift
show(controller: CatalogueController.instantiate(), popupName: "CataloguePopup")
popupControl.isCurrentDisplaying(popupName: "CataloguePopup")
```

### Показ индикатор загрузки

```swift
isLoading = true
```

#### Настройка индикатора
```swift
MUActivityIndicatorControl.defaultStyle = .dark

indicatorControl.style = .lightLarge
indicatorControl.defaultDelay = 0.6
```

#### Показ скелетной анимации
```swift
indicatorControl.isEnabled = false
loadControl.isEnabled = true
```

#### Настройка скелетной анимации
```swift
MULoadControl.multilineCornerRadius = 5
MULoadControl.multilineHeight = 15
MULoadControl.multilineLastLineFillPercent = 70
MULoadControl.gradientBaseColor = .white
```
#### Настройка скелетной анимации вручную
```swift
loadControl.isManualSkeletonable = true
loadControl.shouldCreateOfEmptyItems = false
```

### Контейнер над клавиатурой

Для закрепления **UI элементов** над **клавиатурой** (например **кнопки**) с её анимацией показа и скрытия:
```swift
keyboardControl.containerView = keyboardContainer
```

или можно использовать IBOutlet в xib или storyboard вашего контроллера:
```swift
IB keyboardContainer
```

## Другие настройки MUViewController

### Добавление скролла

Автоматически добавит скролл, если текущий контроллер не помещается на экране девайса по высоте:
```swift
override var hasScroll: Bool { true }
```


### Настройка навигации
```swift
override var hasNavigationBar: Bool { false }
```

Удалит контроллер из списка navigationController.viewControllers после показа другого экрана:
```swift
override var shouldRemoveFromNavigation: Bool { true }
```
Управление нативным жестом для перехода к предыдущему экрану:
```swift
override var interactivePopGestureEnabled: Bool { false }
```
Проверка видимости:
```swift
guard isVisible, isFirstAppear else { return }
```

### Нотификации

Подписание на нотификации, отправленные с помощью NotificationCenter:
```swift
override func subscribeOnCustomNotifications() {
    
    NotificationCenter.addObserver(for: self, forName: .screenHistoryTransactionDidSuccess) { [weak self] _ in
        
        self?.requestObjects()
    }
}
```

## MUFormController

Все экраны с полями ввода проекта нужно наследовать от вашего базового **FormController**, который наследуется от **MUFormController**:

```swift
class FormController: MUFormController
```

#### Базовый функционал:

- валидация данных
- организация работы с полями и кнопки отправки
- переходы между полями
- блокировка кнопки отправки

### Валидация

Поля ввода формы должны соответствовать протоколу:
```swift  
protocol VerifyFieldProtocol {
    
    var value: String { set get }
    var isError: Bool { set get }
    var errorMessage: String? { set get }
    func setError(on: Bool, message: String?)
}
```

Добавления правил валидации для поля:

```swift  
addVerify(

    field.  : passwordField, 
    rules.  : [.required, .minLength(8)], 
    message : "Длина пароля должна быть не менее 8 символов".localize
)
```
 
#### Список правил валидации

```swift  
enum MUValidateRule {
    
    case required
    case email
    case numeric
    case numericFloat
    case minLength(Int)
    case maxLength(Int)
    case minValue(Int)
    case maxValue(Int)
    case allowChar(String)
    case allowRegexp(String)
    case containsAtLeastOneOf([MURegexpClass])
}
```
####  Проверка и отправка формы

Проверка формы на валидность и заполненность:
```swift  
guard isValid, isFilled else { return }
```

Метод для дополнительной кастомной валидации:
```swift 
override func customValidate() -> Bool
```
Метод, который будет вызван после валидации:
```swift 
override func afterValidate()
```
Метод отправки данных для валидной формы:
```swift  
override func submitForm()
```

IBOutlet для назначения кнопки отправки данных. Для неё будет реализована логика блокировки и разблокировки:
```swift  
IB submitButton
```
По нажатию на кнопку продолжить не будет вызван метод submitForm:
```swift  
IB continueButton
```

### Настройка валидации
```swift  
override var fieldsValidation: ValidationOption { .filledOnly }
```

Доступные опции для настройки:
```swift  
enum ValidationOption: String {
   
    case all, filledOnly, activeFieldOnly
}
```

## MUListController

Все простые экраны проекта нужно наследовать от вашего базового **ListController**, который наследуется от **MUListController**.

```swift
class ListController: MUListController
```

#### Базовый функционал:

- подгрузка данных с сети
- группировка данных
- анимация ячеек таблиц
- кэширование данных в файл
- обновление списка по **pull to refresh** 
- подгрузка данных **infinite scrolling**
- показ пустых состояний **empty states**

### Настройка таблицы

Назначить **IBOutlet** в **xib** или **storyboard** для текущего контроллера:
```swift  
IB tableView: UITableView?
IB collectionView: UICollectionView?
```

Добавить ячейку и ее **xib** файл:
```swift  
class ArticleCell: MUTableCell {

    // MARK: - Override methods

    override func setup(with object: MUModel, sender: Any? = nil) {

        super.setup(with: object, sender: sender)

          ...
    }
}
```

Зарегистрировать ячейку из **xib**:
```swift  
registerNib(of: ListCell.self)
```

Если нужно назначить индификатор ячейки, в зависимости от типа данных:
```swift  
override func cellIdentifier(for object: MUModel, at indexPath: IndexPath) -> String?
```
#### Анимация и добавление данных

Добавление анимации для только таблиц UITableView:
```swift  
tableControl.isAnimated = true
tableControl.animationStyle= .fade
```

В модели данных обязательно должен быть назначен **id**:
```swift
final class Entity: MUModel, MUCodable {
    
    var primaryKey: String { return id }
    ...
}
```

Добавить данные в таблицу или коллекцию:
```swift  
objects = items
objects.append(item)
```

#### Запрос данных из сети

Запрос данных из сети нужно реализовать в методе:
```swift  
override func beginRequest()
```

Запросить данные с показом лоадера или скелетной анимации на экране:
```swift  
requestObjects(withIndicator: true)
```

Обновить данные и завершить показ лоадера или скелетной анимации:
```swift  
update(objects: items)
```

Добавить обновление данных по Pull to Refresh:
```swift  
override var hasRefresh: Bool { true }
```

#### Пагинация с бесконечной прокруткой

Добавить поддержку **Infinite scrolling**:
```swift  
override var hasPagination: Bool { true }
```

Получить текущую страницу:
```swift  
let page = paginationControl.page
```

Пример запроса данных с пагинацией:
```swift  
override func beginRequest() {

    interactor.getNews(id: tag.id, page: paginationControl.page) { [weak self] (items) in

        self?.update(objects: items)
    }
}
```

#### Кэширование данных в файл:

Включить поддержку кэширования:
```swift  
override var hasCache: Bool { true }
```

Подготовка модели для кэширования:
```swift  
extension Product {
  
    static let cacheControl: MUCacheControlProtocol = MUCacheControlManager.get(for: Product.self)
}
```

Добавить кэширование:
```swift  
override var cacheControl: MUCacheControlProtocol? { return Product.cacheControl }
```

Сохранение и загрузка данных в кэш:
```swift  
cacheControl.save()
cacheControl.load()
```

## Расширения

### Форматирование

Для удобства, всё форматирование строк сделано через расширение базового класса String

### Даты и время

Время:
```swift  
String.format(time: Date())
String.format(time: Date(), style: .positional, units: [.hour, .minute, .second])
```

Даты:
```swift  
String.format(date: Date(), format: String = "d MMM, HH:mm")
```

### Числа и валюта

Числа:
```swift  
String.format(number: number, minMantissa: 0, maxMantissa: 4)
```

Валютные числа:
```swift  
String.format(price: price)
String.format(rub: priceInRub)
```

### Телефоны

Телефон:
```swift  
String.format(phone: phone)
String.format(phone: phone, to: .e164, onlyNumbers: true)
String.currentPhoneCoutryCode
```

### Регулярные выражения

Проверка:
```swift  
guard String.check(email, regexp: "[0-9a-z]+") else { ... }
```

Поиск:
```swift  
let marches = targetString.matches(for: "[a-zA-Z]+")
```

Замена:
```swift  
let string = rawString.replace(pattern: "[\s]+", with: "")
```

### Маски

Добавление маски:
```swift  
String.mask(template: "+7 999 999 99 99", value: phone)
```

## Требования

-   Swift 4.2+
-   iOS 9.0+

## Установка

### CocoaPods

Add the following to  `Podfile`:

pod 'FrameOk'

### Carthage

Add the following to  `Cartfile`:

github "MobileUpLLC/FrameOk"

### Manual

Загрузите и перетащите файлы из исходной папки в свой проект Xcode

## License

FrameOk is distributed under the [MIT License](https://github.com/MobileUpLLC/FrameOk/blob/develop/LICENSE).
