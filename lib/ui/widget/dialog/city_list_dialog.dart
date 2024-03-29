import 'package:smart_select/smart_select.dart';

class CityListDialog {

  List<S2Choice<String>> options = [
    S2Choice<String>(value: '서울특별시', title: '서울특별시'),
    S2Choice<String>(value: '부산광역시', title: '부산광역시'),
    S2Choice<String>(value: '대구광역시', title: '대구광역시'),
    S2Choice<String>(value: '인천광역시', title: '인천광역시'),
    S2Choice<String>(value: '광주광역시', title: '광주광역시'),
    S2Choice<String>(value: '대전광역시', title: '대전광역시'),
    S2Choice<String>(value: '울산광역시', title: '울산광역시'),
    S2Choice<String>(value: '경기도', title: '경기도'),
    S2Choice<String>(value: '강원도', title: '강원도'),
    S2Choice<String>(value: '충청북도', title: '충청북도'),
    S2Choice<String>(value: '충청남도', title: '충청남도'),
    S2Choice<String>(value: '세종특별자치시', title: '세종특별자치시'),
    S2Choice<String>(value: '전라북도', title: '전라북도'),
    S2Choice<String>(value: '전라남도', title: '전라남도'),
    S2Choice<String>(value: '경상북도', title: '경상북도'),
    S2Choice<String>(value: '경상남도', title: '경상남도'),
    S2Choice<String>(value: '제주특별자치도', title: '제주특별자치도'),
  ];


  List<S2Choice<String>> options0 = [
    S2Choice<String>(value: null, title: null),
  ];

  List<S2Choice<String>> options1 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '강남구', title: '강남구'),
    S2Choice<String>(value: '강동구', title: '강동구'),
    S2Choice<String>(value: '강북구', title: '강북구'),
    S2Choice<String>(value: '강서구', title: '강서구'),
    S2Choice<String>(value: '관악구', title: '관악구'),
    S2Choice<String>(value: '광진구', title: '광진구'),
    S2Choice<String>(value: '구로구', title: '구로구'),
    S2Choice<String>(value: '금천구', title: '금천구'),
    S2Choice<String>(value: '노원구', title: '노원구'),
    S2Choice<String>(value: '도봉구', title: '도봉구'),
    S2Choice<String>(value: '동대문구', title: '동대문구'),
    S2Choice<String>(value: '동작구', title: '동작구'),
    S2Choice<String>(value: '마포구', title: '마포구'),
    S2Choice<String>(value: '서대문구', title: '서대문구'),
    S2Choice<String>(value: '서초구', title: '서초구'),
    S2Choice<String>(value: '성동구', title: '성동구'),
    S2Choice<String>(value: '성북구', title: '성북구'),
    S2Choice<String>(value: '송파구', title: '송파구'),
    S2Choice<String>(value: '양천구', title: '양천구'),
    S2Choice<String>(value: '영등포구', title: '영등포구'),
    S2Choice<String>(value: '용산구', title: '용산구'),
    S2Choice<String>(value: '은평구', title: '은평구'),
    S2Choice<String>(value: '종로구', title: '종로구'),
    S2Choice<String>(value: '중구', title: '중구'),
    S2Choice<String>(value: '중랑구', title: '중랑구'),
  ];

  List<S2Choice<String>> options2 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '중구', title: '중구'),
    S2Choice<String>(value: '서구', title: '서구'),
    S2Choice<String>(value: '동구', title: '동구'),
    S2Choice<String>(value: '영도구', title: '영도구'),
    S2Choice<String>(value: '부산진구', title: '부산진구'),
    S2Choice<String>(value: '동래구', title: '동래구'),
    S2Choice<String>(value: '남구', title: '남구'),
    S2Choice<String>(value: '북구', title: '북구'),
    S2Choice<String>(value: '해운대구', title: '해운대구'),
    S2Choice<String>(value: '사하구', title: '사하구'),
    S2Choice<String>(value: '금정구', title: '금정구'),
    S2Choice<String>(value: '강서구', title: '강서구'),
    S2Choice<String>(value: '연제구', title: '연제구'),
    S2Choice<String>(value: '수영구', title: '수영구'),
    S2Choice<String>(value: '사상구', title: '사상구'),
    S2Choice<String>(value: '기장군', title: '기장군'),
  ];

  List<S2Choice<String>> options3 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '중구', title: '중구'),
    S2Choice<String>(value: '동구', title: '동구'),
    S2Choice<String>(value: '서구', title: '서구'),
    S2Choice<String>(value: '남구', title: '남구'),
    S2Choice<String>(value: '북구', title: '북구'),
    S2Choice<String>(value: '수성구', title: '수성구'),
    S2Choice<String>(value: '달서구', title: '달서구'),
    S2Choice<String>(value: '달성군', title: '달성군'),
  ];

  List<S2Choice<String>> options4 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '중구', title: '중구'),
    S2Choice<String>(value: '동구', title: '동구'),
    S2Choice<String>(value: '미추홀구', title: '미추홀구'),
    S2Choice<String>(value: '연수구', title: '연수구'),
    S2Choice<String>(value: '남동구', title: '남동구'),
    S2Choice<String>(value: '부평구', title: '부평구'),
    S2Choice<String>(value: '계양구', title: '계양구'),
    S2Choice<String>(value: '서구', title: '서구'),
    S2Choice<String>(value: '강화군', title: '강화군'),
    S2Choice<String>(value: '옹진군', title: '옹진군'),
  ];

  List<S2Choice<String>> options5 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '동구', title: '동구'),
    S2Choice<String>(value: '서구', title: '서구'),
    S2Choice<String>(value: '남구', title: '남구'),
    S2Choice<String>(value: '북구', title: '북구'),
    S2Choice<String>(value: '광산구', title: '광산구'),
  ];

  List<S2Choice<String>> options6 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '동구', title: '동구'),
    S2Choice<String>(value: '중구', title: '중구'),
    S2Choice<String>(value: '서구', title: '서구'),
    S2Choice<String>(value: '유성구', title: '유성구'),
    S2Choice<String>(value: '대덕구', title: '대덕구'),
  ];

  List<S2Choice<String>> options7 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '중구', title: '중구'),
    S2Choice<String>(value: '남구', title: '남구'),
    S2Choice<String>(value: '동구', title: '동구'),
    S2Choice<String>(value: '북구', title: '북구'),
    S2Choice<String>(value: '울주군', title: '울주군'),
  ];

  List<S2Choice<String>> options8 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '강남구', title: '가평군'),
    S2Choice<String>(value: '고양시 덕양구', title: '고양시 덕양구'),
    S2Choice<String>(value: '고양시 일산동구', title: '고양시 일산동구'),
    S2Choice<String>(value: '고양시 일산서구', title: '고양시 일산서구'),
    S2Choice<String>(value: '과천시', title: '과천시'),
    S2Choice<String>(value: '광명시', title: '광명시'),
    S2Choice<String>(value: '광주시', title: '광주시'),
    S2Choice<String>(value: '구리시', title: '구리시'),
    S2Choice<String>(value: '군포시', title: '군포시'),
    S2Choice<String>(value: '김포시', title: '김포시'),
    S2Choice<String>(value: '남양주시', title: '남양주시'),
    S2Choice<String>(value: '동두천시', title: '동두천시'),
    S2Choice<String>(value: '부천시 소사구', title: '부천시 소사구'),
    S2Choice<String>(value: '부천시 오정구', title: '부천시 오정구'),
    S2Choice<String>(value: '부천시 원미구', title: '부천시 원미구'),
    S2Choice<String>(value: '성남시 분당구', title: '성남시 분당구'),
    S2Choice<String>(value: '성남시 수정구', title: '성남시 수정구'),
    S2Choice<String>(value: '성남시 중원구', title: '성남시 중원구'),
    S2Choice<String>(value: '수원시 권선구', title: '수원시 권선구'),
    S2Choice<String>(value: '수원시 영통구', title: '수원시 영통구'),
    S2Choice<String>(value: '수원시 장안구', title: '수원시 장안구'),
    S2Choice<String>(value: '수원시 팔달구', title: '수원시 팔달구'),
    S2Choice<String>(value: '시흥시', title: '시흥시'),
    S2Choice<String>(value: '안산시 단원구', title: '안산시 단원구'),
    S2Choice<String>(value: '안산시 상록구', title: '안산시 상록구'),
    S2Choice<String>(value: '안성시', title: '안성시'),
    S2Choice<String>(value: '안양시 동안구', title: '안양시 동안구'),
    S2Choice<String>(value: '안양시 만안구', title: '안양시 만안구'),
    S2Choice<String>(value: '양주시', title: '양주시'),
    S2Choice<String>(value: '양평군', title: '양평군'),
    S2Choice<String>(value: '여주군', title: '여주군'),
    S2Choice<String>(value: '연천군', title: '연천군'),
    S2Choice<String>(value: '오산시', title: '오산시'),
    S2Choice<String>(value: '용인시 기흥구', title: '용인시 기흥구'),
    S2Choice<String>(value: '용인시 수지구', title: '용인시 수지구'),
    S2Choice<String>(value: '용인시 처인구', title: '용인시 처인구'),
    S2Choice<String>(value: '의왕시', title: '의왕시'),
    S2Choice<String>(value: '의정부시', title: '의정부시'),
    S2Choice<String>(value: '이천시', title: '이천시'),
    S2Choice<String>(value: '파주시', title: '파주시'),
    S2Choice<String>(value: '평택시', title: '평택시'),
    S2Choice<String>(value: '포천시', title: '포천시'),
    S2Choice<String>(value: '하남시', title: '하남시'),
    S2Choice<String>(value: '화성시', title: '화성시'),
  ];

  List<S2Choice<String>> options9 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '춘천시', title: '춘천시'),
    S2Choice<String>(value: '원주시', title: '원주시'),
    S2Choice<String>(value: '강릉시', title: '강릉시'),
    S2Choice<String>(value: '동해시', title: '동해시'),
    S2Choice<String>(value: '태백시', title: '태백시'),
    S2Choice<String>(value: '속초시', title: '속초시'),
    S2Choice<String>(value: '삼척시', title: '삼척시'),
    S2Choice<String>(value: '홍천군', title: '홍천군'),
    S2Choice<String>(value: '횡성군', title: '횡성군'),
    S2Choice<String>(value: '영월군', title: '영월군'),
    S2Choice<String>(value: '평창군', title: '평창군'),
    S2Choice<String>(value: '정선군', title: '정선군'),
    S2Choice<String>(value: '철원군', title: '철원군'),
    S2Choice<String>(value: '화천군', title: '화천군'),
    S2Choice<String>(value: '양구군', title: '양구군'),
    S2Choice<String>(value: '인제군', title: '인제군'),
    S2Choice<String>(value: '고성군', title: '고성군'),
    S2Choice<String>(value: '양양군', title: '양양군'),
  ];

  List<S2Choice<String>> options10 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '청주시 상당구', title: '청주시 상당구'),
    S2Choice<String>(value: '청주시 흥덕구', title: '청주시 흥덕구'),
    S2Choice<String>(value: '충주시', title: '충주시'),
    S2Choice<String>(value: '제천시', title: '제천시'),
    S2Choice<String>(value: '청주시 청원구', title: '청주시 청원구'),
    S2Choice<String>(value: '보은군', title: '보은군'),
    S2Choice<String>(value: '옥천군', title: '옥천군'),
    S2Choice<String>(value: '영동군', title: '영동군'),
    S2Choice<String>(value: '증평군', title: '증평군'),
    S2Choice<String>(value: '진천군', title: '진천군'),
    S2Choice<String>(value: '괴산군', title: '괴산군'),
    S2Choice<String>(value: '음성군', title: '음성군'),
    S2Choice<String>(value: '단양군', title: '단양군'),
    S2Choice<String>(value: '청주시 서원구', title: '청주시 서원구'),
  ];

  List<S2Choice<String>> options11 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '천안시 동남구', title: '천안시 동남구'),
    S2Choice<String>(value: '천안시 서북구', title: '천안시 서북구'),
    S2Choice<String>(value: '공주시', title: '공주시'),
    S2Choice<String>(value: '보령시', title: '보령시'),
    S2Choice<String>(value: '아산시', title: '아산시'),
    S2Choice<String>(value: '서산시', title: '서산시'),
    S2Choice<String>(value: '논산시', title: '논산시'),
    S2Choice<String>(value: '계룡시', title: '계룡시'),
    S2Choice<String>(value: '당진시', title: '당진시'),
    S2Choice<String>(value: '금산군', title: '금산군'),
    S2Choice<String>(value: '연기군', title: '연기군'),
    S2Choice<String>(value: '부여군', title: '부여군'),
    S2Choice<String>(value: '서천군', title: '서천군'),
    S2Choice<String>(value: '청양군', title: '청양군'),
    S2Choice<String>(value: '홍성군', title: '홍성군'),
    S2Choice<String>(value: '예산군', title: '예산군'),
    S2Choice<String>(value: '태안군', title: '태안군'),
  ];

  List<S2Choice<String>> options12 = [
    S2Choice<String>(value: '미정', title: '미정'),
  ];

  List<S2Choice<String>> options13 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '전주시 덕진구', title: '전주시 덕진구'),
    S2Choice<String>(value: '전주시 완산구', title: '전주시 완산구'),
    S2Choice<String>(value: '군산시', title: '군산시'),
    S2Choice<String>(value: '익산시', title: '익산시'),
    S2Choice<String>(value: '정읍시', title: '정읍시'),
    S2Choice<String>(value: '남원시', title: '남원시'),
    S2Choice<String>(value: '김제시', title: '김제시'),
    S2Choice<String>(value: '완주군', title: '완주군'),
    S2Choice<String>(value: '진안군', title: '진안군'),
    S2Choice<String>(value: '무주군', title: '무주군'),
    S2Choice<String>(value: '장수군', title: '장수군'),
    S2Choice<String>(value: '임실군', title: '임실군'),
    S2Choice<String>(value: '순창군', title: '순창군'),
    S2Choice<String>(value: '고창군', title: '고창군'),
    S2Choice<String>(value: '부안군', title: '부안군'),
  ];

  List<S2Choice<String>> options14 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '목포시', title: '목포시'),
    S2Choice<String>(value: '여수시', title: '여수시'),
    S2Choice<String>(value: '순천시', title: '순천시'),
    S2Choice<String>(value: '나주시', title: '나주시'),
    S2Choice<String>(value: '광양시', title: '광양시'),
    S2Choice<String>(value: '담양군', title: '담양군'),
    S2Choice<String>(value: '곡성군', title: '곡성군'),
    S2Choice<String>(value: '구례군', title: '구례군'),
    S2Choice<String>(value: '고흥군', title: '고흥군'),
    S2Choice<String>(value: '보성군', title: '보성군'),
    S2Choice<String>(value: '화순군', title: '화순군'),
    S2Choice<String>(value: '장흥군', title: '장흥군'),
    S2Choice<String>(value: '강진군', title: '강진군'),
    S2Choice<String>(value: '해남군', title: '해남군'),
    S2Choice<String>(value: '영암군', title: '영암군'),
    S2Choice<String>(value: '무안군', title: '무안군'),
    S2Choice<String>(value: '함평군', title: '함평군'),
    S2Choice<String>(value: '영광군', title: '영광군'),
    S2Choice<String>(value: '장성군', title: '장성군'),
    S2Choice<String>(value: '완도군', title: '완도군'),
    S2Choice<String>(value: '진도군', title: '진도군'),
    S2Choice<String>(value: '신안군', title: '신안군'),
  ];

  List<S2Choice<String>> options15 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '포항시 남구', title: '포항시 남구'),
    S2Choice<String>(value: '포항시 북구', title: '포항시 북구'),
    S2Choice<String>(value: '경주시', title: '경주시'),
    S2Choice<String>(value: '김천시', title: '김천시'),
    S2Choice<String>(value: '안동시', title: '안동시'),
    S2Choice<String>(value: '구미시', title: '구미시'),
    S2Choice<String>(value: '영주시', title: '영주시'),
    S2Choice<String>(value: '영천시', title: '영천시'),
    S2Choice<String>(value: '상주시', title: '상주시'),
    S2Choice<String>(value: '문경시', title: '문경시'),
    S2Choice<String>(value: '경산시', title: '경산시'),
    S2Choice<String>(value: '군위군', title: '군위군'),
    S2Choice<String>(value: '의성군', title: '의성군'),
    S2Choice<String>(value: '청송군', title: '청송군'),
    S2Choice<String>(value: '영양군', title: '영양군'),
    S2Choice<String>(value: '영덕군', title: '영덕군'),
    S2Choice<String>(value: '청도군', title: '청도군'),
    S2Choice<String>(value: '고령군', title: '고령군'),
    S2Choice<String>(value: '성주군', title: '성주군'),
    S2Choice<String>(value: '칠곡군', title: '칠곡군'),
    S2Choice<String>(value: '예천군', title: '예천군'),
    S2Choice<String>(value: '봉화군', title: '봉화군'),
    S2Choice<String>(value: '울진군', title: '울진군'),
    S2Choice<String>(value: '울릉군', title: '울릉군'),
  ];

  List<S2Choice<String>> options16 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '창원시 마산합포구', title: '창원시 마산합포구'),
    S2Choice<String>(value: '창원시 마산회원구', title: '창원시 마산회원구'),
    S2Choice<String>(value: '창원시 성산구', title: '창원시 성산구'),
    S2Choice<String>(value: '창원시 의창구', title: '창원시 의창구'),
    S2Choice<String>(value: '창원시 진해구', title: '창원시 진해구'),
    S2Choice<String>(value: '진주시', title: '진주시'),
    S2Choice<String>(value: '통영시', title: '통영시'),
    S2Choice<String>(value: '사천시', title: '사천시'),
    S2Choice<String>(value: '김해시', title: '김해시'),
    S2Choice<String>(value: '밀양시', title: '밀양시'),
    S2Choice<String>(value: '거제시', title: '거제시'),
    S2Choice<String>(value: '양산시', title: '양산시'),
    S2Choice<String>(value: '의령군', title: '의령군'),
    S2Choice<String>(value: '함안군', title: '함안군'),
    S2Choice<String>(value: '창녕군', title: '창녕군'),
    S2Choice<String>(value: '고성군', title: '고성군'),
    S2Choice<String>(value: '남해군', title: '남해군'),
    S2Choice<String>(value: '하동군', title: '하동군'),
    S2Choice<String>(value: '산청군', title: '산청군'),
    S2Choice<String>(value: '함양군', title: '함양군'),
    S2Choice<String>(value: '거창군', title: '거창군'),
    S2Choice<String>(value: '합천군', title: '합천군'),
  ];

  List<S2Choice<String>> options17 = [
    S2Choice<String>(value: '미정', title: '미정'),
    S2Choice<String>(value: '제주시', title: '제주시'),
    S2Choice<String>(value: '서귀포시', title: '서귀포시'),
  ];

}
