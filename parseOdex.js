class BankXmlAdapter {
  getValue(xml, tag) {
    const openTag = `<${tag}>`;
    const closeTag = `</${tag}>`;

    const start = xml.indexOf(openTag);
    const end = xml.indexOf(closeTag);

    if (start === -1 || end === -1) return "";

    return xml.substring(start + openTag.length, end).trim();
  }

  convert(xmlString) {
    return JSON.stringify({
      name: this.getValue(xmlString, "adi"),
      surname: this.getValue(xmlString, "soyadi"),
      balance: Number(this.getValue(xmlString, "bakiye")),
      lastTransaction: this.getValue(xmlString, "sonIslem")
    }, null, 2);
  }
}


const inputXml = `
    <kullanici>
      <adi>Meltem</adi>
      <soyadi>Demir</soyadi>
      <bakiye>5000</bakiye>
      <sonIslem>Transfer İşlemi</sonIslem>
    </kullanici>
  `;

const adapter = new BankXmlAdapter();
const jsonOutput = adapter.convert(inputXml);

console.log(jsonOutput);



/**
 class SoapUserService {
getXml() {
return "<kullanici>
          <ad>Ahmet</ad>
          <soyad>Yilmaz</soyad>
          <son_islem>Giris Yapildi</son_islem>
        </kullanici>";
}
}

class UserXmlAdapter {
  constructor(soapService) {  
    this.soapService = soapService;
  }

getData() {
const xml = this.soapService.getXml();
const getVal = (tag) => xml.split(<${tag}>)[1].split(</${tag}>)[0];

return {
  name: getVal("ad"),
  surname: getVal("soyad"),
  last_action: getVal("son_islem")
};
}
}

const adapter = new UserXmlAdapter(new SoapUserService());
console.log(adapter.getData());
 */