import { request } from '@umijs/max';
import { PersonalProductAPI } from '../../../products/personalproduct/data';

/** 个人商品手动创建参数（移动端专用） */
export interface CreatePersonalProductManualParams {
  /** 商品类型（必填） */
  type: PersonalProductAPI.TypeKey;
  /** 主人ID（必填） */
  owner: string;
  /** 商品信息ID（必填） */
  productInfoId: string;
  /** 品相 */
  condition?: PersonalProductAPI.ConditionKey;
  /** 评级卡 */
  ratedCard?: PersonalProductAPI.RatedCard;
  /** 价格 */
  price?: number;
  /** 库存 */
  quantity?: number;
  /** 备注 */
  notes?: string;
  /** 图片 */
  images?: string[];
  /** 是否主图 */
  isMainImage?: boolean;
  // 注意：status 字段不包含在创建参数中，默认为上架状态
}

/** 个人商品手动批量创建参数（移动端专用） */
export interface BatchCreatePersonalProductManualParams {
  /** 商品类型（必填） */
  type: PersonalProductAPI.TypeKey;
  /** 主人ID（必填） */
  owner: string;
  /** 商品信息ID（必填） */
  productInfoId: string;
  /** 品相 */
  condition?: PersonalProductAPI.ConditionKey;
  /** 评级卡 */
  ratedCard?: PersonalProductAPI.RatedCard;
  /** 价格 */
  price?: number;
  /** 库存 */
  quantity?: number;
  /** 备注 */
  notes?: string;
  /** 图片 */
  images?: string[];
  /** 是否主图 */
  isMainImage?: boolean;
  /** 商品状态（批量创建时可指定，默认为已上架） */
  status?: PersonalProductAPI.StatusKey;
}

/** 个人商品手动整体更新参数（移动端专用） */
export interface UpdatePersonalProductManualParams {
  /** 品相 */
  condition?: PersonalProductAPI.ConditionKey;
  /** 评级卡 */
  ratedCard?: PersonalProductAPI.RatedCard;
  /** 价格 */
  price?: number;
  /** 库存 */
  quantity?: number;
  /** 备注 */
  notes?: string;
  /** 图片 */
  images?: string[];
  /** 状态 */
  status?: PersonalProductAPI.StatusKey;
  /** 是否主图 */
  isMainImage?: boolean;
}

/** 创建个人商品（移动端专用） */
export async function createPersonalProductForMobile(params: CreatePersonalProductManualParams) {
  return request<API.ApiResponse<string>>('/api/products/personal-products/mobile-create', {
    method: 'POST',
    data: params,
  });
}

/** 批量创建个人商品（移动端专用） */
export async function batchCreatePersonalProductForMobile(paramsList: BatchCreatePersonalProductManualParams[]) {
  return request<API.ApiResponse<string[]>>('/api/products/personal-products/batch-mobile-create', {
    method: 'POST',
    data: paramsList,
  });
}

/** 整体更新个人商品（移动端专用） */
export async function updatePersonalProductForMobile(personalProductId: string, params: UpdatePersonalProductManualParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/mobile-update`, {
    method: 'PUT',
    data: params,
  });
}

/** 批量整体更新个人商品（移动端专用） */
export async function batchUpdatePersonalProductForMobile(paramsList: (UpdatePersonalProductManualParams & { id: string })[]) {
  return request<API.ApiResponse<null>>('/api/products/personal-products/batch-mobile-update', {
    method: 'POST',
    data: paramsList,
  });
}
