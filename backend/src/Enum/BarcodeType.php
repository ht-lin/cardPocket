<?php

declare(strict_types=1);

namespace App\Enum;

enum BarcodeType: string
{
    case QR_CODE     = 'QR_CODE';
    case CODE_128    = 'CODE_128';
    case EAN_13      = 'EAN_13';
    case CODE_39     = 'CODE_39';
    case PDF_417     = 'PDF_417';
    case AZTEC       = 'AZTEC';
    case EAN_8       = 'EAN_8';
    case UPC_A       = 'UPC_A';
    case DATA_MATRIX = 'DATA_MATRIX';
}
