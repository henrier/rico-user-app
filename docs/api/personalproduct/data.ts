import { UserShopAPI } from '@/pages/shop/usershop/data';

import { ProductInfoAPI } from '../productinfo/data';
import { PackagedProductAPI } from '../packagedproduct/data';
import { RatingCompanyAPI } from '../ratingcompany/data';

export namespace PersonalProductAPI {

  /** 类型枚举值 */
  type TypeKey = 'RAWCARD' | 'BOX' | 'RATEDCARD';

  /** 类型枚举选项 */
  export const typeOptions = [
    { label: '普通卡', value: 'RAWCARD' },
    { label: '原盒', value: 'BOX' },
    { label: '评级卡', value: 'RATEDCARD' }
  ];

  /** 状态枚举值 */
  type StatusKey = 'PENDINGLISTING' | 'LISTED' | 'SOLDOUT';

  /** 状态枚举选项 */
  export const statusOptions = [
    { label: '待上架', value: 'PENDINGLISTING' },
    { label: '已上架', value: 'LISTED' },
    { label: '已售罄', value: 'SOLDOUT' }
  ];

  /** 品相枚举值 */
  type ConditionKey = 'MINT' | 'NEARMINT' | 'LIGHTLYPLAYED' | 'DAMAGED';

  /** 品相枚举选项 */
  export const conditionOptions = [
    { label: '完美品相', value: 'MINT' },
    { label: '近完美品相', value: 'NEARMINT' },
    { label: '轻微磨损', value: 'LIGHTLYPLAYED' },
    { label: '有损伤', value: 'DAMAGED' }
  ];

  /** RatingInfo */
  export interface RatingInfoVO {
    /** 名称 */
    name: string;
    /** 值 */
    value: string;
  }

  /** 评级卡 */
  export interface RatedCardVO {
    /** 评级公司 */
    ratingCompany: RatingCompanyAPI.RatingCompanyVO;
    /** 卡牌评分 */
    cardScore: string;
    /** 评级卡编号 */
    gradedCardNumber: string;
    /** 评级信息 */
    ratingInfos: RatingInfoVO[];
  }

  /** 打包信息 */
  export interface BundleInfoVO {
    /** 允许拆包销售 */
    allowUnbundleSale: boolean;
    /** 已售罄 */
    isSoldOut: boolean;
    /** 打包数量 */
    bundleQuantity: number;
  }

  /** 个人商品详情视图 */
  export interface PersonalProductVO {
    /** 主键 */
    id: string;
    /** 商品信息 */
    productInfo: ProductInfoAPI.ProductInfoVO;
    /** 价格 */
    price: number;
    /** 备注 */
    notes: string;
    /** 图片 */
    images: string[];
    /** 是否主图 */
    isMainImage: boolean;
    /** 主人 */
    owner: UserShopAPI.UserShopVO;
    /** 类型 */
    type: TypeKey;
    /** 状态 */
    status: StatusKey;
    /** 评级卡 */
    ratedCard: RatedCardVO;
    /** 数量 */
    quantity: number;
    /** 品相 */
    condition: ConditionKey;
    /** 限时价格 */
    limitedTimePrice: number;
    /** 截止时间 */
    deadline: string;
    /** 打包商品 */
    bundleProduct: PackagedProductAPI.PackagedProductVO;
    /** 打包信息 */
    bundleInfo: BundleInfoVO;
    /** 审计信息 */
    auditMetadata: API.AuditMetadata;
  }

  /** 创建个人商品参数 */
  export interface CreatePersonalProductParams {
    /** 商品信息 */
    productInfo: string;
    /** 主人 */
    owner: string;
    /** 类型 */
    type: TypeKey;
    /** 状态 */
    status: StatusKey;
    /** 数量 */
    quantity: number;
  }

  /** 创建个人商品（全参数）参数 */
  export interface CreatePersonalProductWithAllFieldsParams {
    /** 商品信息 */
    productInfo: string;
    /** 价格 */
    price?: number;
    /** 备注 */
    notes?: string;
    /** 图片 */
    images?: string[];
    /** 是否主图 */
    isMainImage?: boolean;
    /** 主人 */
    owner: string;
    /** 类型 */
    type: TypeKey;
    /** 状态 */
    status: StatusKey;
    /** 评级卡 */
    ratedCard?: RatedCardVO;
    /** 数量 */
    quantity: number;
    /** 品相 */
    condition?: ConditionKey;
    /** 限时价格 */
    limitedTimePrice?: number;
    /** 截止时间 */
    deadline?: string;
    /** 打包商品 */
    bundleProduct?: string;
  }

  /** 修改商品信息参数 */
  export interface UpdatePersonalProductProductInfoParams {
    /** 商品信息 */
    productInfo: string;
  }

  /** 修改价格参数 */
  export interface UpdatePersonalProductPriceParams {
    /** 价格 */
    price: number;
  }

  /** 修改备注参数 */
  export interface UpdatePersonalProductNotesParams {
    /** 备注 */
    notes: string;
  }

  /** 修改是否主图参数 */
  export interface UpdatePersonalProductIsMainImageParams {
    /** 是否主图 */
    isMainImage: boolean;
  }

  /** 修改主人参数 */
  export interface UpdatePersonalProductOwnerParams {
    /** 主人 */
    owner: string;
  }

  /** 修改类型参数 */
  export interface UpdatePersonalProductTypeParams {
    /** 类型 */
    type: TypeKey;
  }

  /** 修改状态参数 */
  export interface UpdatePersonalProductStatusParams {
    /** 状态 */
    status: StatusKey;
  }

  /** 修改评级卡参数 */
  export interface UpdatePersonalProductRatedCardParams {
    /** 评级卡 */
    ratedCard: RatedCardVO;
  }

  /** 修改数量参数 */
  export interface UpdatePersonalProductQuantityParams {
    /** 数量 */
    quantity: number;
  }

  /** 修改品相参数 */
  export interface UpdatePersonalProductConditionParams {
    /** 品相 */
    condition: ConditionKey;
  }

  /** 修改限时价格参数 */
  export interface UpdatePersonalProductLimitedTimePriceParams {
    /** 限时价格 */
    limitedTimePrice: number;
  }

  /** 修改截止时间参数 */
  export interface UpdatePersonalProductDeadlineParams {
    /** 截止时间 */
    deadline: string;
  }

  /** 修改打包商品参数 */
  export interface UpdatePersonalProductBundleProductParams {
    /** 打包商品 */
    bundleProduct: string;
  }

  /** 修改图片参数 */
  export interface UpdatePersonalProductImagesParams {
    /** 图片 */
    images: string[];
  }

  /** 分页查询个人商品参数 */
  export interface PersonalProductPageParams extends API.PageParams {
    /** 商品信息 */
    productInfo?: string;
    /** 价格最小值 */
    minPrice?: number;
    /** 价格最大值 */
    maxPrice?: number;
    /** 备注 */
    notes?: string;
    /** 图片 */
    images?: string[];
    /** 是否主图 */
    isMainImage?: boolean;
    /** 主人 */
    owner?: string;
    /** 类型 */
    type?: TypeKey;
    /** 状态 */
    status?: StatusKey;
    /** 评级卡 - 评级公司 */
    ratedCardRatingCompany?: string;
    /** 评级卡 - 卡牌评分 */
    ratedCardCardScore?: string;
    /** 评级卡 - 评级卡编号 */
    ratedCardGradedCardNumber?: string;
    /** 评级卡 - 评级信息 - 名称 */
    ratedCardRatingInfosName?: string;
    /** 评级卡 - 评级信息 - 值 */
    ratedCardRatingInfosValue?: string;
    /** 数量最小值 */
    minQuantity?: number;
    /** 数量最大值 */
    maxQuantity?: number;
    /** 品相 */
    condition?: ConditionKey;
    /** 限时价格最小值 */
    minLimitedTimePrice?: number;
    /** 限时价格最大值 */
    maxLimitedTimePrice?: number;
    /** 截止时间开始时间 */
    deadlineStart?: string;
    /** 截止时间结束时间 */
    deadlineEnd?: string;
    /** 打包商品 */
    bundleProduct?: string;
    
    /** 创建时间范围开始 */
    createdAtStart?: string;
    /** 创建时间范围结束 */
    createdAtEnd?: string;
    /** 更新时间范围开始 */
    updatedAtStart?: string;
    /** 更新时间范围结束 */
    updatedAtEnd?: string;
    /** 创建者（模糊查询） */
    createdBy?: string;
    /** 更新者（模糊查询） */
    updatedBy?: string;
  }

} 