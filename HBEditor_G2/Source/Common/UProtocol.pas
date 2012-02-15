{*******************************************************************************
  ����: dmzn@163.com 2009-10-31
  ����: ͨ��Э��
*******************************************************************************}
unit UProtocol;

interface

const
  cHead_DataSend          = $4842;          //���ݷ���
  cHead_DataRecv          = $4153;          //���ݽ���
  cHead_DataRecv_Hi       = $41;
  cHead_DataRecv_Low      = $53;

  cCmd_SetBorder          = $07;            //���ñ߿�
  cCmd_SetScanMode        = $08;            //ɨ��ģʽ
  cCmd_SetELevel          = $09;            //��Ч��ƽ

  cCmd_ConnCtrl           = $10;            //����������
  cCmd_SetDeviceNo        = $11;            //�����豸��
  cCmd_ResetCtrl          = $12;            //��λ������
  cCmd_SetBright          = $13;            //��������
  cCmd_SetBrightTime      = $14;            //ʱ������
  cCmd_AdjustTime         = $15;            //У׼ʱ��
  cCmd_OpenOrClose        = $16;            //������Ļ
  cCmd_OCTime             = $17;            //����ʱ��
  cCmd_PlayDays           = $18;            //��������
  cCmd_ReadStatus         = $19;            //��ȡ״̬
  cCmd_SetScreenWH        = $1A;            //��Ļ���
  cCmd_DataBegin          = $1B;            //��ʼ֡
  cCmd_DataEnd            = $1C;            //����֡

  cCmd_SendPicData        = $20;            //����ͼƬ
  cCmd_SendAnimate        = $30;            //���Ͷ���
  cCmd_SendSimuClock      = $40;            //ģ��ʱ��
  cCmd_SendAreaTime       = $41;            //������Ϣ

  sFlag_OK                = 1;              //�ɹ�
  sFlag_Err               = 0;              //ʧ��
  sFlag_BroadCast         = $FFFF;          //�㲥ģʽ

type
  //Ӧ���׼Э��ͷ
  THead_Respond_Base = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
  end;

  //����������(PC -> Ctrl)
  THead_Send_ConnCtrl = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FExtend: array[0..5] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //����������Ӧ��(PC <- Ctrl)
  THead_Respond_ConnCtrl = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FScreen: array[0..1] of Byte;           //����,��
    FCRC16: Word;                           //У��λ
  end;

  //ָ���������豸��(PC -> Ctrl)
  THead_Send_SetDeviceNo = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FNo: Word;                              //���
    FCommand: Byte;                         //�����
    FExtend: array[0..5] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //������Ӧ��(PC <- Ctrl)
  THead_Respond_SetDeviceNo = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //��λ������(PC -> Ctrl)
  THead_Send_ResetCtrl = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FExtend: array[0..5] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //��λ������(PC <- Ctrl)
  THead_Respond_ResetCtrl = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //�趨��ʾ������(PC -> Ctrl)
  THead_Send_SetBright = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FBright: Byte;                          //����ֵ
    FExtend: array[0..4] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //�趨��ʾ������(PC <- Ctrl)
  THead_Respond_SetBright = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //�趨ʱ��ο�������(PC -> Ctrl)
  THead_Send_SetBrightTime = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FBright: Byte;                          //����ֵ
    FTimeBegin: array[0..1]of Byte;         //��ʼʱ��
    FTimeEnd: array[0..1]of Byte;           //����ʱ��
    FExtend: Byte;                          //����
    FCRC16: Word;                           //У��λ
  end;

  //�趨ʱ��ο�������(PC <- Ctrl)
  THead_Respond_SetBrightTime = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //У׼������ʱ��(PC -> Ctrl)
  THead_Send_AdjustTime = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FTime: array[0..6] of Byte;             //У׼ʱ��
    FCRC16: Word;                           //У��λ
  end;

  //У׼������ʱ��(PC <- Ctrl)
  THead_Respond_AdjustTime = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //�ֶ���/����Ļ(PC -> Ctrl)
  THead_Send_OpenOrClose = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //���ر��(0,��;1,��)
    FExtend: array[0..4] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //�ֶ���/����Ļ(PC <- Ctrl)
  THead_Respond_OpenOrClose = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //�Զ�������Ļʱ��(PC -> Ctrl)
  THead_Send_OCTime = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //���ر��(0,��;1,��)
    FTimeBegin: array[0..1] of Byte;        //��ʼʱ��
    FTimeEnd: array[0..1] of Byte;          //����ʱ��
    FExtend: Byte;                          //����
    FCRC16: Word;                           //У��λ
  end;

  //�Զ�������Ļʱ��(PC <- Ctrl)
  THead_Respond_OCTime = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //���ò�������(PC -> Ctrl)
  THead_Send_PlayDays = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FDays: Word;                            //��������
    FExtend: array[0..3] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //���ò�������(PC <- Ctrl)
  THead_Respond_PlayDays = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //��ȡ����������״̬(PC -> Ctrl)
  THead_Send_ReadStatus = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FExtend: array[0..5] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //��ȡ����������״̬(PC <- Ctrl)
  THead_Respond_ReadStatus = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //״̬��(1,��;0,��)
    FScreenWH: array[0..1] of Byte;         //����
    FPlayDays: array[0..1] of Word;         //��������
    FOpenTime: array[0..1] of Byte;         //����ʱ��
    FCloseTime: array[0..1] of Byte;        //����ʱ��
    FBright: Byte;                          //��ǰ����
    FItemID: array[0..7] of Byte;           //Ļ���
    FNowTime: array[0..6] of Byte;          //��ǰʱ��
    FExtend: array[0..5] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //������Ļ���(PC -> Ctrl)
  THead_Send_SetScreenWH = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FScreenWH: array[0..1] of Byte;         //��Ļ���
    FExtend: array[0..3] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //������Ļ���(PC <- Ctrl)
  THead_Respond_SetScreenWH = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //���ݷ���֡(PC -> Ctrl)
  THead_Send_DataBegin = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FAreaNum: Byte;                         //��������
    FColorType: Byte;                       //��Ļ����
    FExtend: array[0..3] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //���ݷ���֡(PC <- Ctrl)
  THead_Respond_DataBegin = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //���ݽ���֡(PC -> Ctrl)
  THead_Send_DataEnd = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FExtend: array[0..5] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  //���ݽ���֡(PC <- Ctrl)
  THead_Respond_DataEnd = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //ͼƬ����֡(PC -> Ctrl)
  THead_Send_PicData = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FIndexID: Byte;                         //������
    FLevel: Byte;                           //���ȼ�
    FPosX: Word;
    FPosY: Word;                            //��������
    FWidth: Word;
    FHeight: Word;                          //������
    FAllID: Word;
    FNowID: Word;                           //��Ļ,��ǰĻ
    FExtend: array[0..8] of Byte;           //����
    FMode: array[0..6] of Byte;             //����ģʽ
    //FData: array of Byte;                   //����
    //FCRC16: Word;                           //У��λ
  end;

  //ͼƬӦ��֡(PC <- Ctrl)
  THead_Respond_PicData = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //��������֡(PC -> Ctrl)
  THead_Send_Animate = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FIndexID: Byte;                         //������
    FLevel: Byte;                           //���ȼ�
    FPosX: Word;
    FPosY: Word;                            //��������
    FWidth: Word;
    FHeight: Word;                          //������
    FAllID: Word;
    FNowID: Word;                           //��֡��,��ǰ֡
    FSpeed: Byte;                           //�����ٶ�
    FExtend: array[0..4] of Byte;           //����
    //FData: array of Byte;                   //����
    //FCRC16: Word;                           //У��λ
  end;

  //����Ӧ��֡(PC <- Ctrl)
  THead_Respond_Animate = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //����ʱ����Ϣ(PC -> Ctrl)
  THead_Send_AreaTime = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FIndexID: Byte;                         //������
    FLevel: Byte;                           //���ȼ�
    FPosX: Word;
    FPosY: Word;                            //��������
    FWidth: Word;
    FHeight: Word;                          //������
    FParam: Word;                           //��������
    FModeChar: Byte;                        //�ַ�ģʽ(0,�ַ�;1,����)
    FModeLine: Byte;                        //����ģʽ(0,��;1,��)
    FModeDate: Byte;                        //����ѡ��(0,����;1,��ʾ)
    FModeWeek: Byte;                        //����ѡ��(0,����;1,��ʾ)
    FModeTime: Byte;                        //ʱ��ѡ��(0,����;1,��ʾ)
    FExtend: array[0..12] of Byte;          //����
    FCRC16: Word;                           //У��λ
  end;

  //����ʱ����Ϣ(PC <- Ctrl)
  THead_Respond_AreaTime = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  //ģ��ʱ��(PC -> Ctrl)
  THead_Send_Clock = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FIndexID: Byte;                         //������
    FLevel: Byte;                           //���ȼ�
    FPosX: Word;
    FPosY: Word;                            //��������
    FWidth: Word;
    FHeight: Word;                          //������
    FParam: Word;                           //��������
    FPointX: Word;
    FPointY: Word;                          //����Բ������
    FZhenColor: array[0..2] of Byte;        //������ɫ(ʱ,��,��)
    FExtend: array[0..0] of Byte;           //����
    //FData: array of Byte;                 //ģ�����
    //FCRC16: Word;                         //У��λ
  end;

  //ģ��ʱ��(PC <- Ctrl)
  THead_Respond_Clock = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  THead_Send_SetBorder = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FHasBorder: Byte;                       //�Ƿ���ʾ(0,����ʾ;1,��ʾ)
    FEffect: Byte;                          //��Ч
    FSpeed: Byte;                           //�ٶ�
    FWidth: Byte;                           //���
    FExtend: array[0..1] of Byte;           //���� 
    FCRC16: Word;                           //У��λ
  end;

  THead_Respond_SetBorder = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  THead_Send_ScanMode = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FKeepMode: Byte;                        //����ģʽ(1,����;0,������)
    FExtend: array[0..4] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  THead_Respond_ScanMode = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

  THead_Send_ELevel = packed record
    FHead: Word;                            //֡ͷ
    FLen: Word;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FKeepMode: Byte;                        //����ģʽ(1,����;0,������)
    FExtend: array[0..4] of Byte;           //����
    FCRC16: Word;                           //У��λ
  end;

  THead_Respond_ELevel = packed record
    FHead: Word;                            //֡ͷ
    FLen: Byte;                             //֡����
    FCardType: Byte;                        //�����
    FDevice: Word;                          //�豸��
    FCommand: Byte;                         //�����
    FFlag: Byte;                            //��־(1,�ɹ�;0,ʧ��)
    FCRC16: Word;                           //У��λ
  end;

const
  cSize_Respond_Base = SizeOf(THead_Respond_Base);
  cSize_Head_Send_ConnCtrl = SizeOf(THead_Send_ConnCtrl);
  cSize_Head_Respond_ConnCtrl = SizeOf(THead_Respond_ConnCtrl);

  cSize_Head_Send_SetDeviceNo = SizeOf(THead_Send_SetDeviceNo);
  cSize_Head_Respond_SetDeviceNo = SizeOf(THead_Respond_SetDeviceNo);

  cSize_Head_Send_ResetCtrl = SizeOf(THead_Send_ResetCtrl);
  cSize_Head_Respond_ResetCtrl = SizeOf(THead_Respond_ResetCtrl);

  cSize_Head_Send_SetBright = SizeOf(THead_Send_SetBright);
  cSize_Head_Respond_SetBright = SizeOf(THead_Respond_SetBright);

  cSize_Head_Send_SetBrightTime = SizeOf(THead_Send_SetBrightTime);
  cSize_Head_Respond_SetBrightTime = SizeOf(THead_Respond_SetBrightTime);

  cSize_Head_Send_AdjustTime = SizeOf(THead_Send_AdjustTime);
  cSize_Head_Respond_AdjustTime = SizeOf(THead_Respond_AdjustTime);

  cSize_Head_Send_OpenOrClose = SizeOf(THead_Send_OpenOrClose);
  cSize_Head_Respond_OpenOrClose = SizeOf(THead_Respond_OpenOrClose);

  cSize_Head_Send_OCTime = SizeOf(THead_Send_OCTime);
  cSize_Head_Respond_OCTime = SizeOf(THead_Respond_OCTime);

  cSize_Head_Send_PlayDays = SizeOf(THead_Send_PlayDays);
  cSize_Head_Respond_PlayDays = SizeOf(THead_Respond_PlayDays);

  cSize_Head_Send_ReadStatus = SizeOf(THead_Send_ReadStatus);
  cSize_Head_Respond_ReadStatus = SizeOf(THead_Respond_ReadStatus);

  cSize_Head_Send_SetScreenWH = SizeOf(THead_Send_SetScreenWH);
  cSize_Head_Respond_SetScreenWH = SizeOf(THead_Respond_SetScreenWH);

  cSize_Head_Send_DataBegin = SizeOf(THead_Send_DataBegin);
  cSize_Head_Respond_DataBegin = SizeOf(THead_Respond_DataBegin);

  cSize_Head_Send_DataEnd = SizeOf(THead_Send_DataEnd);
  cSize_Head_Respond_DataEnd = SizeOf(THead_Respond_DataEnd);

  cSize_Head_Send_PicData = SizeOf(THead_Send_PicData);
  cSize_Head_Respond_PicData = SizeOf(THead_Respond_PicData);

  cSize_Head_Send_Animate = SizeOf(THead_Send_Animate);
  cSize_Head_Respond_Animate = SizeOf(THead_Respond_Animate);

  cSize_Head_Send_AreaTime = SizeOf(THead_Send_AreaTime);
  cSize_Head_Respond_AreaTime = SizeOf(THead_Respond_AreaTime);

  cSize_Head_Send_Clock = SizeOf(THead_Send_Clock);
  cSize_Head_Respond_Clock = SizeOf(THead_Respond_Clock);

  cSize_Head_Send_SetBorder = SizeOf(THead_Send_SetBorder);
  cSize_Head_Respond_SetBorder = SizeOf(THead_Respond_SetBorder);

  cSize_Head_Send_ScanMode = SizeOf(THead_Send_ScanMode);
  cSize_Head_Respond_ScanMode = SizeOf(THead_Respond_ScanMode);

  cSize_Head_Send_ELevel = SizeOf(THead_Send_ELevel);
  cSize_Head_Respond_ELevel = SizeOf(THead_Respond_ELevel);
implementation

end.
