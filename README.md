# SoundHub 개요 

혼자서 음악을 만드는 일은 어렵습니다. 음악 한 트랙에는 여러 악기가 필요한데, 여러 악기를 동시에 잘 다루기는 쉽지 않기 때문이죠. 
하지만 음악을, 마치 **GitHub**처럼 여러 사람이 협업해서 만든다면 어떨까요? 아래와 같이 말이에요!

1. 기타만 잘 치는 철수가 음악을 올림
2. 베이스를 잘 치는 영희가 베이스 트랙을 만들어서 Pull-Request를 보냄
3. 철수가 Pull-Request를 Merge함
4. 다른 사람들은 각자의 취향대로 영희의 트랙을 넣거나 빼서 철수의 노래를 즐김

정말 재미있을 것 같지 않나요? 그래서 우리는 **SoundHub**를 만들었습니다!
[데모영상](http://blog.e-sung.net/demo-video/SoundHub-Demo.mp4)


# 어떤 기능이 있나요?

* 음악 업로드
  * 앨범표지, bpm, 저자 등의 정보를 메타정보에서 추출하고
  * 메타정보에 해당내용이 없으면, 사용자에게 입력을 요구합니다.
  * 입력받은 메타정보를 파일에 덮어쓰고 서버에 업로드합니다.
  
  ![uploadMusic](https://github.com/e-sung/SoundHub/blob/master/previews/upload1.gif) ![uploadMusic](https://github.com/e-sung/SoundHub/blob/master/previews/upload2.gif)

* 음악 녹음
  * 여러 AudioUnit들을 활용하여 각종 효과를 입혀서 녹음할 수 있습니다.
  * "댓글"용 음악을 녹음 할 때는, 원본음악을 들으면서 녹음할 수 있습니다. 
  * <img src="https://raw.githubusercontent.com/e-sung/SoundHub/master/previews/record.png" alt="record Music" width="270">

* 음악 청취
  * 여러 트랙을 동시에 들을 수 있습니다.
  * 재생 중 선택적으로 트랙들을 껏다 켤 수 있습니다
  * <img src="https://github.com/e-sung/SoundHub/blob/master/previews/play.png" alt="Play Music" width="270">

* 음악 합치기
  * 원저작자는, 자신의 음악에 달린 댓글들 중 마음에 드는 것들을, 마스터트랙에 합칠 수 있습니다.
  * 합쳐진 댓글들은, Mixed-Comments로 별도로 관리됩니다. 
  * <img src="https://github.com/e-sung/SoundHub/blob/master/previews/merge.gif" alt="Play Music" width="270">

* 음악 찾기
  * 장르별, 악기별로 음악과 뮤지션을 탐색할 수 있습니다.

* 그 외에도 여러 기능이 있습니다! 설치해서 사용해 보세요!


# 어떤 기능이 추가될 예정인가요?

* 플레이리스트 연속재생
* 회원간 DirectMessage
* 음악 검색
* Inter-App-Audio를 활용하여 외부 악기앱을 사용해 녹음
* 메트로눔 
* 음악 믹싱을 클라이언트사이드에서 하기

재미있게 보셨나요? Issue재기 및 Pull-Request는 언제든지 환영입니다. 궁금한 점이 있으시면 언제든 dev.esung@gmail.com으로 연락주세요!
