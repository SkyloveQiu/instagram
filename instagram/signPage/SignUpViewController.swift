import UIKit
import AVOSCloud


class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //Image View 用于显示用户头像
    @IBOutlet weak var avaImg: UIImageView!
    //
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    //
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    //滚动视图
    @IBOutlet weak var scrollview: UIScrollView!
    
    // 根据需要，设置滚动视图的高度
    var scrollViewHeight:CGFloat = 0
    // 获取虚拟键盘的大小
    var keyboard:CGRect = CGRect()
    
    //按钮
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBAction func signUpBtn_clicked(_ sender: Any) {
        // 隐藏keyboard
        self.view.endEditing(true)
        
        if usernameTxt.text!.isEmpty ||
            passwordTxt.text!.isEmpty ||
            repeatPasswordTxt.text!.isEmpty ||
            emailTxt.text!.isEmpty ||
            fullnameTxt.text!.isEmpty ||
            bioTxt.text!.isEmpty ||
            webTxt.text!.isEmpty
        {
            //弹出对话框
            let alert = UIAlertController(title: "请注意", message: "请填写好所有的字段", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
            
        }
        
        if passwordTxt.text != repeatPasswordTxt.text {
            let alert = UIAlertController(title: "请注意", message: "两次输入的密码不一致", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
        }
        
        // 提交数据到leancloud
        let user = AVUser()
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passwordTxt.text
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        user["web"] = webTxt.text?.lowercased()
        user["gender"] = ""
        
        //转换头像数据并发送到服务器
        let avaData = avaImg.image!.jpegData(compressionQuality: 0.5)
        let avaFile = AVFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        
        
        //保存信息至服务器
        user.signUpInBackground{ (success:Bool, error:Error?) in
            if success{
                print("用户注册成功!")
                

                
                
                AVUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: { (user:AVUser?, error:Error?) in
                    if let user = user {
                        
                        UserDefaults.standard.set(user.username, forKey: "username")
                        UserDefaults.standard.synchronize()
                        
                        let appdelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appdelegate.login()
                        
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        }
        //let testUser1 = AVUser.current()
        print("注册按钮被按下")
    }
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        print("取消按钮被按下")
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // 滚动视图的frame size
        scrollview.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollview.contentSize.height = self.view.frame.height
        scrollViewHeight = self.view.frame.height
        // 检测键盘出现或消失的状态
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyboard),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg(recognizer:)))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(imgTap)
        let viewWidth = self.view.frame.width

        //改变avaImg的外观为圆形
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        //UI布局
        avaImg.frame = CGRect(x: self.view.frame.width / 2 , y: 40, width: 80, height: 80)
        
        usernameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y + 90, width: viewWidth - 10, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: viewWidth - 10, height: 30)
        repeatPasswordTxt.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        
        emailTxt.frame = CGRect(x: 10, y: repeatPasswordTxt.frame.origin.y + 60, width: viewWidth - 10, height: 30)
        fullnameTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: viewWidth - 10, height: 30)
        bioTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: viewWidth - 10, height: 30)
        webTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 40, width: viewWidth - 10, height: 30)
        
        signUpBtn.frame = CGRect(x: 20, y: webTxt.frame.origin.y + 50, width: viewWidth / 4, height: 30)
        cancelBtn.frame = CGRect(x: viewWidth - signUpBtn.frame.width + 20, y: signUpBtn.frame.origin.y, width: signUpBtn.frame.width, height: signUpBtn.frame.height)
        //设置按钮圆角
        signUpBtn.layer.cornerRadius = signUpBtn.frame.width / 20
        cancelBtn.layer.cornerRadius = cancelBtn.frame.width / 20
        signUpBtn.clipsToBounds = true
        cancelBtn.clipsToBounds = true
        //设置背景图
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showKeyboard(notificaton:Notification)  {
        var userInfo = notificaton.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollview.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollview.contentInset = contentInset
    }
    @objc func hideKeyboard(notification:Notification) {
        // 当虚拟键盘消失后，将滚动视图的实际高度改变为屏幕的高度值。
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollview.contentInset = contentInset
    }
    
    // 隐藏视图中的虚拟键盘
    @objc func hideKeyboardTap(recognizer:UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
    }
    
    // 调出照片获取器选择照片
    @objc func loadImg(recognizer:UITapGestureRecognizer) -> Void {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    // 关联选择好的照片图像到image view
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            print("select picture error!")
            return
        }
        
        avaImg.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    // 用户取消获取器操作时调用的方法
    //func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //    self.dismiss(animated: true, completion: nil)
    //}
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
