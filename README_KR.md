# AXION VCE 첫 실리콘 프로토타입

버전: **0.2 (AXION Gen0)**

이 프로젝트는 우리가 설계한 GPU 구조를 한 번에 완성하려는 것이 아니라,
**가장 적은 비용으로 실제 반도체를 만들어 핵심 아이디어를 검증**하기 위한 1세대 실험용 칩입니다.

## 이번 칩에 들어가는 것

- VCE(Vector Compute Engine) 1개
- 8비트 V-Core 연산기 1개
- SA-Core(Special AI Core) 1개
- INT8 × INT8 AI용 곱셈-누산(MAC)
- 덧셈, 뺄셈, 곱셈, AND, XOR, MAX

완전한 GPU가 아니므로 화면 출력, GDDR 메모리 컨트롤러, 수천 개 V-Core,
RT-Core, PCIe 등은 아직 넣지 않습니다.

첫 칩에서 가장 중요한 목표는:

> "우리가 만든 VCE/V-Core/SA-Core 개념이 실제 실리콘에서도 정상 동작하는가?"

를 확인하는 것입니다.

## 왜 이렇게 작게 시작하나요?

GPU 전체를 첫 시도에 ASIC으로 만들면 설계 비용과 실패 위험이 매우 커집니다.
먼저 작은 MPW 타일에서 연산 코어를 검증한 뒤 다음 버전에서 병렬 코어 수를 늘리는 것이 안전합니다.

## 실제 제작 전 반드시 확인할 것

GitHub Actions에서 다음 세 항목이 모두 성공해야 합니다.

- GDS build
- Tiny Tapeout precheck
- Gate-level test

이 ZIP 안에는 자동 생성 전의 설계 소스가 들어 있습니다.
최종 GDS는 Tiny Tapeout 공식 빌드 환경에서 생성해야 합니다.

## 제어 방법

`LOAD_A`, `LOAD_B`, `EXECUTE`, `CLEAR_ACC`는 클럭 상승 엣지에서 처리되는
active-high 신호입니다. A와 B는 서로 다른 클럭에서 로드한 뒤 실행합니다.
Opcode `110`을 실행하면 `uo_out`에 새 누산값의 ReLU/포화 결과가 바로 나옵니다.
`OUT_SEL=1`은 디버그용으로 24비트 누산기의 하위 8비트를 출력합니다.

실물 칩 테스트 절차는 `HARDWARE_TEST.md`에 정리되어 있습니다.
