import '../../constants/IConstants.dart';
import '../../constants/features.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/language.dart';
import '../../utils/prefUtils.dart';
import 'package:velocity_x/velocity_x.dart';
class SetLanguage extends VxMutation<GroceStore> {
  String code ;
  bool? value;
  SetLanguage({required String this.code});
  perform() {
    print("language change to : $code");
    PrefUtils.prefs!.setString("languagecode", code);
    store!.language.languages.where((element) => element.code == code)
        .map((e) {
      print("lcods:${e.code}");
      IConstants.languageId = Features.ismultivendor?e.code!:e.id!;
      // IConstants.languageCode = e.code!;
      store!.language.language = new Language(code: code, id: e.id, branch: e.branch, localName: e.localName, status: e.status, selected: true);
    }).toList();
    //store!.language.languages = store!.language.languages.reversed.toList();
  }
}

class SetLanguageList extends VxMutation<GroceStore>{
  Map<String,dynamic> json;
  List<Language> lidt =[];
  String activelang = "en";
  SetLanguageList(this.json);
  @override
  perform() {
    // TODO: implement perform
    print("language_json: ${json['languages']}");
    lidt.clear();
    lidt.add(new Language(status: "1",branch:PrefUtils.prefs!.getString("branch"),/*"999"*/localName: "English",code: "en",id: "",selected: false));
    if(Features.isLanguageModule)
if(Features.ismultivendor) {
  if (json['languages'] != null) {
    json['languages'].forEach((v) {
      if (new Language.fromJson(v).status == "0" &&
          new Language.fromJson(v).code != "en")
        lidt.add(new Language.fromJson(v));
    });
    store!.language.languages = lidt.reversed.toList();
  }
  else {
    SetLanguage(code: activelang);
  }

}
    else{
  if (json['languages'] != null) {
    json['languages'].forEach((v) {
      if(new Language.fromJson(v).status == "0" && new Language.fromJson(v).code != "en")
        lidt.add(new Language.fromJson(v));
    });
    store!.language.languages = lidt.reversed.toList();
  }
  else{
    SetLanguage(code: activelang);
  }
    }


    if(PrefUtils.prefs!.containsKey("languagecode"))
      activelang = PrefUtils.prefs!.getString("languagecode")!;
    print("active lang...."+PrefUtils.prefs!.getString("languagecode").toString());
    SetLanguage(code: activelang);
  }
}